# create_transfer_secrets.sh

A single, idempotent helper script that:

- Creates or updates **AWS Transfer Family** user secrets in **AWS Secrets Manager** (admin or user mapping).
- **Does not overwrite** existing secrets by default (shows diffs; `--overwrite` to apply).
- Uses a local **RC file** for **prompt defaults only**, never to auto-fill values.
- Can **test SFTP logins** for all users in your CSV (`--test-logins` or `--test-only`).
- Safely saves RC updates while **preserving untouched lines** and **backing up** the RC file.

> Script filename: `create_transfer_secrets.sh`

---

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [How the RC file works](#how-the-rc-file-works)
- [Secret schema (plaintext key/value)](#secret-schema-plaintext-keyvalue)
- [CSV format](#csv-format)
- [Usage](#usage)
  - [Common flags](#common-flags)
  - [SFTP testing flags](#sftp-testing-flags)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Security notes](#security-notes)
- [Exit behavior](#exit-behavior)
- [License](#license)

---

## Features

- **Idempotent**: examines each secret; creates new ones; reports differences for existing ones.
- **Safe by default**: refuses to overwrite unless `--overwrite` is present.
- **RC-aware prompts**: reads `.sftp_transfer.rc` only to **display defaults in prompts** when a value is missing.
- **Preserve your RC**: only keys you change via CLI or prompt are updated; all other lines and comments are preserved.
- **Automatic RC backups**: before saving, the script creates a timestamped backup, e.g. `.sftp_transfer.rc.20250829-1342`.
- **SFTP login testing**: checks each user with `sshpass` + `sftp` and records success/failure and latency; optional JSON/CSV reports.
- **Cross-platform friendly**: avoids unsafe `eval`; quotes JSON properly for AWS CLI.

---

## Requirements

- **AWS CLI v2**
- **jq**
- **sshpass**, **sftp** (OpenSSH client), **timeout** (from coreutils) — for SFTP testing
- AWS permissions to call:
  - `secretsmanager:CreateSecret`, `secretsmanager:PutSecretValue`, `secretsmanager:DescribeSecret`, `secretsmanager:GetSecretValue`, `secretsmanager:TagResource`
  - `transfer:DescribeServer`
  - `iam:GetRole`

> Network: SFTP testing needs outbound access to `--sftp-host` on TCP `--sftp-port` (default 22).

---

## Installation

```bash
# make it executable
chmod +x create_transfer_secrets.sh

# (optional) place it on PATH
sudo mv create_transfer_secrets.sh /usr/local/bin/
```

---

## How the RC file works

- Default RC path: **`./.sftp_transfer.rc`** (override with `--rc <path>`).
- The RC file is **only used to pre-fill prompts** when a required value is missing.
- **CLI flags always win.** Any value you pass on the CLI overrides prompts/RC.
- After a run, the script **updates only the keys you changed** (via CLI or prompt) and **preserves everything else** (order, comments, unknown keys), and **creates a backup** first.

### RC backup format

When saving, a backup is written next to your RC file using the pattern:

```
.sftp_transfer.rc.YYYYMMDD-HHMM
```

**Example:** `.sftp_transfer.rc.20250829-1342`

### RC sample

```ini
# .sftp_transfer.rc
ACCOUNT_NUM=123456789012
REGION=us-east-1
SERVER_ID=s-1234567890abcdefg
S3_BUCKET=sftp.example.gov
SITE=example-prod
CSV_FILE=sftp_user_passwords.csv
ROLE_ARN=arn:aws:iam::123456789012:role/sftp-simple2-full-bucket-role
ADMIN_MODE=user
AWS_PROFILE=default
SFTP_HOST=sftp.example.gov
SFTP_PORT=22
TIMEOUT=20
```

> The script trims leading/trailing spaces and surrounding quotes when reading RC defaults.

---

## Secret schema (plaintext key/value)

Each secret is stored under:

```
aws/transfer/<SERVER_ID>/<username>
```

With a **JSON object** (all values are strings), e.g.:

```json
{
  "Password": "••••••••",
  "Role": "arn:aws:iam::123456789012:role/sftp-simple2-full-bucket-role",
  "HomeDirectoryType": "LOGICAL",
  "HomeDirectoryDetails": "[{"Entry":"/","Target":"/s3-bucket/example-prod/${Transfer:UserName}/incoming"}]"
}
```

> **Note**: `HomeDirectoryDetails` is stored as a **string** containing a JSON array (compatibility with your originals).

### Path mappings

- **Admin mode** (`--admin`):
  - `Target`: `/<bucket>/${Transfer:UserName}`
- **User mode** (`--user`):
  - `Target`: `/<bucket>/<site>/${Transfer:UserName}/incoming`

---

## CSV format

- A simple **comma-separated** file with headers is fine.
- Only the first two fields are used: `username,password`.
- Blank lines, commented lines (`#`), and the header row are ignored.

**Example:**

```csv
username,password
alice,CorrectHorseBatteryStaple
bob,S0methingS3cret!
# charlie, (no password; skipped)
```

---

## Usage

### Common flags

```
./create_transfer_secrets.sh [flags]

--account <num>       AWS account (12 digits)          [prompted if missing]
--server-id <id>      Transfer Family server ID        [prompted if missing]
--bucket <name>       S3 bucket                        [prompted if missing]
--site <name>         Site path part (user mode)       [prompted if missing]
--csv <path>          CSV with "username,password"     [prompted if missing]
--admin | --user      Select mapping mode              [prompted if missing]

--region <aws-region> Default us-east-1 (prompt shows RC default if any)
--role-arn <arn>      Defaults to arn:aws:iam::<ACCOUNT>:role/sftp-simple2-full-bucket-role
--profile <name>      AWS CLI profile
--rc <path>           RC file path (default ./.sftp_transfer.rc)
--dry-run             Show actions without modifying AWS
--overwrite           Allow updating existing secrets when they differ
--no-save-rc          Do NOT write/update the RC file after the run
-h, --help            Show help
```

### SFTP testing flags

```
--test-logins         After secret work, test SFTP logins for all CSV users
--test-only           Only test SFTP logins (skip AWS secret work)
--sftp-host <host>    Default: sftp.nbs.example.gov (prompt shows RC default if any)
--sftp-port <port>    Default: 22 (prompt shows RC default if any)
--timeout <sec>       Timeout for each login attempt (default 20)
--report-json <file>  Save test results as JSON
--report-csv  <file>  Save test results as CSV
```

---

## Examples

**User mapping to a site; no overwrite by default; then test logins**

```bash
./create_transfer_secrets.sh   --account 123456789012   --server-id s-728b8f1eee2212345   --bucket sftp.example.gov   --site example-prod   --csv sftp_user_passwords.csv   --user   --test-logins   --report-json sftp_tests.json   --report-csv  sftp_tests.csv
```

**Admin mapping; allow overwrites when different**

```bash
./create_transfer_secrets.sh   --csv sftp_admin_users.csv   --admin   --overwrite
```

**Test-only (no AWS calls); custom host/port**

```bash
./create_transfer_secrets.sh   --csv users.csv   --test-only   --sftp-host sftp.example.gov   --sftp-port 22   --timeout 25   --report-csv login_results.csv
```

**Run without saving RC changes**

```bash
./create_transfer_secrets.sh   --user --csv users.csv   --no-save-rc
```

---

## Troubleshooting

- **“usage: sftp …” on test**  
  We avoided `-b -` to prevent stdin conflicts with `sshpass`. The script sends `exit` via here-string. If you still see issues, verify `sshpass`, `sftp`, and `timeout` are installed and on PATH.

- **Host key prompts**  
  The tester uses `-o StrictHostKeyChecking=no`. If your security policy requires it, change to `accept-new` (OpenSSH 8.4+) and pre-seed `known_hosts`.

- **Permission errors (AWS)**  
  Ensure your IAM principal allows the actions listed in **Requirements**, and that `--region` matches your resources (e.g., `us-east-1`).

- **Secrets not overwritten**  
  This is by design. Use `--overwrite` to apply differences. `--dry-run` shows what would change without writing.

- **RC didn’t keep my values**  
  Only keys you set via CLI or prompt are updated. Everything else is left untouched. A timestamped backup is created every time the RC is saved.

---

## Security notes

- Treat the CSV and RC files as **sensitive** (they can contain usernames and configuration details).
- Secrets are written to **AWS Secrets Manager**; restrict access via IAM and resource policies.
- Avoid checking CSV/RC into source control; consider using per-run temps or `--no-save-rc` when appropriate.

---

## Exit behavior

- The script exits non-zero on fatal errors (missing tools, AWS failures, etc.).
- For SFTP tests, per-user results are printed and optionally written to JSON/CSV. The overall exit status is **0** unless a fatal error occurs.

---

## License

This script and README are provided as-is, without warranty. Use under your organization’s preferred internal terms.
