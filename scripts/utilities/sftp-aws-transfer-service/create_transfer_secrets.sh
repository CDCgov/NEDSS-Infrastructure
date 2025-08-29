#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# ---------------------------------------------
# Persistent defaults
# ---------------------------------------------
RC_FILE="./.sftp_transfer.rc"
REGION_DEFAULT="us-east-1"   # AWS region format

# runtime flags (with sane defaults)
DRY_RUN=0
OVERWRITE=0
ADMIN_MODE=""         # admin|user
NO_SAVE_RC=0          # set by --no-save-rc

# Testing flags
TEST_LOGINS=0
TEST_ONLY=0
SFTP_HOST=""
SFTP_PORT=""
TIMEOUT=20
REPORT_JSON=""
REPORT_CSV=""

# user-supplied vars (CLI only; RC will NOT auto-populate these)
ACCOUNT_NUM=""
REGION=""
SERVER_ID=""
S3_BUCKET=""
SITE=""
CSV_FILE=""
ROLE_ARN=""
AWS_PROFILE=""

# Track which keys are modified by CLI/prompt
declare -A TOUCHED=()

# ---------------------------------------------
# Helpers
# ---------------------------------------------
die(){ echo "ERROR: $*" >&2; exit 1; }
have(){ command -v "$1" >/dev/null 2>&1; }

aws_run() {
  local flags=()
  [[ -n "${REGION:-}" ]]      && flags+=(--region "$REGION")
  [[ -n "${AWS_PROFILE:-}" ]] && flags+=(--profile "$AWS_PROFILE")
  aws "${flags[@]}" "$@"
}

prompt_var(){
  # prompt_var VAR "Prompt" "default"
  local var="$1" prompt="$2" def="${3:-}"
  local reply
  if [[ -n "$def" ]]; then
    read -r -p "$prompt [$def]: " reply || true
    reply="${reply:-$def}"
  else
    read -r -p "$prompt: " reply || true
  fi
  printf -v "$var" '%s' "$reply"
  TOUCHED["$var"]=1
  export "$var"
}

# Trim-leading/trailing space, strip optional surrounding quotes
_trim_value(){
  local v="$1"
  # remove leading/trailing whitespace
  v="${v#"${v%%[![:space:]]*}"}"
  v="${v%"${v##*[![:space:]]}"}"
  # strip matching single/double quotes around entire value
  if [[ ( "$v" == \"*\" && "$v" == *\" ) || ( "$v" == \'*\' && "$v" == *\' ) ]]; then
    v="${v:1:${#v}-2}"
  fi
  printf '%s' "$v"
}

rc_get(){
  # Return value from RC file (last occurrence), trimmed; does NOT set runtime vars
  local key="$1"
  [[ -f "$RC_FILE" ]] || { echo ""; return; }
  local line
  line="$(grep -E "^[[:space:]]*${key}[[:space:]]*=" "$RC_FILE" | tail -n 1 || true)"
  [[ -z "$line" ]] && { echo ""; return; }
  line="${line#*=}"                      # part after '='
  line="$(_trim_value "$line")"
  printf '%s' "$line"
}

# Save RC: only update keys that were touched; preserve all other lines verbatim; backup first
save_rc_preserve(){
  if (( NO_SAVE_RC )); then
    echo "Skipped saving RC (per --no-save-rc)."
    return 0
  fi

  local tmp_rc="$(mktemp)"
  local backup=""
  if [[ -f "$RC_FILE" ]]; then
    # backup with date/hour/minute suffix
    local ts
    ts="$(date +%Y%m%d-%H%M)"
    backup="${RC_FILE}.${ts}"
    cp -p -- "$RC_FILE" "$backup" || true
    # start from existing content
    cp -p -- "$RC_FILE" "$tmp_rc"
  else
    # create new with a header
    {
      echo "# Created by create_transfer_secrets.sh"
      echo "# $(date -u +'%Y-%m-%dT%H:%MZ')"
    } > "$tmp_rc"
  fi

  # Helper: replace or append KEY=value in $tmp_rc only if TOUCHED
  _rc_set(){
    local key="$1" val="$2"
    local esc_val
    esc_val="$(printf '%s' "$val" | sed -e 's/[&/\\]/\\&/g')"
    if grep -q -E "^[[:space:]]*${key}[[:space:]]*=" "$tmp_rc"; then
      # replace line
      sed -E -i "s|^[[:space:]]*${key}[[:space:]]*=.*|${key}=${esc_val}|" "$tmp_rc"
    else
      printf '%s=%s\n' "$key" "$val" >> "$tmp_rc"
    fi
  }

  # For each known key: if touched, set; otherwise preserve existing content
  [[ -n "${TOUCHED[ACCOUNT_NUM]:-}"    ]] && _rc_set "ACCOUNT_NUM" "$ACCOUNT_NUM"
  [[ -n "${TOUCHED[REGION]:-}"         ]] && _rc_set "REGION" "$REGION"
  [[ -n "${TOUCHED[SERVER_ID]:-}"      ]] && _rc_set "SERVER_ID" "$SERVER_ID"
  [[ -n "${TOUCHED[S3_BUCKET]:-}"      ]] && _rc_set "S3_BUCKET" "$S3_BUCKET"
  [[ -n "${TOUCHED[SITE]:-}"           ]] && _rc_set "SITE" "$SITE"
  [[ -n "${TOUCHED[CSV_FILE]:-}"       ]] && _rc_set "CSV_FILE" "$CSV_FILE"
  [[ -n "${TOUCHED[ROLE_ARN]:-}"       ]] && _rc_set "ROLE_ARN" "$ROLE_ARN"
  [[ -n "${TOUCHED[ADMIN_MODE]:-}"     ]] && _rc_set "ADMIN_MODE" "$ADMIN_MODE"
  [[ -n "${TOUCHED[AWS_PROFILE]:-}"    ]] && _rc_set "AWS_PROFILE" "$AWS_PROFILE"
  [[ -n "${TOUCHED[SFTP_HOST]:-}"      ]] && _rc_set "SFTP_HOST" "$SFTP_HOST"
  [[ -n "${TOUCHED[SFTP_PORT]:-}"      ]] && _rc_set "SFTP_PORT" "$SFTP_PORT"
  [[ -n "${TOUCHED[TIMEOUT]:-}"        ]] && _rc_set "TIMEOUT" "$TIMEOUT"

  # Move tmp -> RC atomically
  mv -- "$tmp_rc" "$RC_FILE"
  if [[ -n "$backup" ]]; then
    echo "Saved RC and created backup: $backup"
  else
    echo "Saved RC: $RC_FILE"
  fi
}

usage(){
cat <<'USAGE'
Usage: create_transfer_secrets.sh [flags]

Required (CLI or will be prompted; RC values appear only as prompt defaults):
  --account <num>         AWS account number (12 digits)
  --server-id <id>        Transfer Family server ID (e.g., s-abc1234567890)
  --bucket <name>         S3 bucket for Transfer (e.g., sftp.nbs.example.gov)
  --site <name>           Site folder (e.g., example-prod) [required for --user]
  --csv <path>            CSV with "username,password"
  --admin | --user        Admin mapping or User/Prod mapping

Optional:
  --region <aws-region>   Defaults to us-east-1 (prompt shows RC default if present)
  --role-arn <arn>        Defaults to arn:aws:iam::<ACCOUNT>:role/sftp-simple2-full-bucket-role
  --profile <name>        AWS CLI profile to use
  --rc <path>             RC file path (default ./.sftp_transfer.rc)
  --dry-run               Show actions without changing anything
  --overwrite             Allow updating an existing secret if it differs
  --no-save-rc            Do not write/update the RC file after the run
  -h, --help              Show help

SFTP testing (replaces 05_sftp_test_users.sh):
  --test-logins           After secret work, test SFTP logins for all CSV users
  --test-only             Only test SFTP logins (skip secret creation/update)
  --sftp-host <host>      Default: sftp.nbs.example.gov (prompt shows RC default if present)
  --sftp-port <port>      Default: 22 (prompt shows RC default if present)
  --timeout <sec>         Connection timeout (default 20)
  --report-json <file>    Save test results as JSON
  --report-csv  <file>    Save test results as CSV

Behavior:
  * Secret: aws/transfer/<SERVER_ID>/<username>
  * Stored as plaintext key/value pairs (JSON object), with:
      Password: "<string>"
      Role: "<string>"
      HomeDirectoryType: "LOGICAL"
      HomeDirectoryDetails: "<string containing JSON array>"
  * Admin mapping: /<bucket>/${Transfer:UserName}
  * User mapping:  /<bucket>/<site>/${Transfer:UserName}/incoming

Default policy: If a secret already exists, DO NOT overwrite it.
The script will print a diff summary. Use --overwrite to apply changes.

RC model:
- RC values NEVER auto-fill variables; they ONLY appear as defaults in prompts.
- When saving, only keys set via CLI or prompt are updated; all other lines in the RC are preserved verbatim.
- A backup is saved as "<rc>.<YYYYMMDD-HHMM>" before writing.
USAGE
}

# ---------------------------------------------
# Handle --rc early so prompts show the right defaults
# ---------------------------------------------
args=("$@")
for ((i=0; i<${#args[@]}; i++)); do
  if [[ "${args[i]}" == "--rc" && -n "${args[i+1]:-}" ]]; then
    RC_FILE="${args[i+1]}"
    break
  fi
done

# ---------------------------------------------
# Parse CLI (CLI sets runtime vars; RC will NOT auto-populate)
# ---------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --account) ACCOUNT_NUM="$2"; TOUCHED[ACCOUNT_NUM]=1; shift 2;;
    --region) REGION="$2"; TOUCHED[REGION]=1; shift 2;;
    --server-id) SERVER_ID="$2"; TOUCHED[SERVER_ID]=1; shift 2;;
    --bucket) S3_BUCKET="$2"; TOUCHED[S3_BUCKET]=1; shift 2;;
    --site) SITE="$2"; TOUCHED[SITE]=1; shift 2;;
    --csv) CSV_FILE="$2"; TOUCHED[CSV_FILE]=1; shift 2;;
    --role-arn) ROLE_ARN="$2"; TOUCHED[ROLE_ARN]=1; shift 2;;
    --profile) AWS_PROFILE="$2"; TOUCHED[AWS_PROFILE]=1; shift 2;;
    --rc) RC_FILE="$2"; shift 2;;
    --dry-run) DRY_RUN=1; shift;;
    --overwrite) OVERWRITE=1; shift;;
    --no-save-rc) NO_SAVE_RC=1; shift;;
    --admin) ADMIN_MODE="admin"; TOUCHED[ADMIN_MODE]=1; shift;;
    --user) ADMIN_MODE="user"; TOUCHED[ADMIN_MODE]=1; shift;;
    --test-logins) TEST_LOGINS=1; shift;;
    --test-only) TEST_ONLY=1; shift;;
    --sftp-host) SFTP_HOST="$2"; TOUCHED[SFTP_HOST]=1; shift 2;;
    --sftp-port) SFTP_PORT="$2"; TOUCHED[SFTP_PORT]=1; shift 2;;
    --timeout) TIMEOUT="$2"; TOUCHED[TIMEOUT]=1; shift 2;;
    --report-json) REPORT_JSON="$2"; shift 2;;
    --report-csv) REPORT_CSV="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) die "Unknown argument: $1";;
  esac
done

# ---------------------------------------------
# Prompts (use RC values ONLY as prompt defaults)
# ---------------------------------------------
if (( TEST_ONLY == 0 )); then
  [[ -n "$ACCOUNT_NUM" ]] || prompt_var ACCOUNT_NUM \
    "Enter AWS account number (12 digits)" "$(rc_get ACCOUNT_NUM)"

  # Region default hierarchy: CLI > RC default > REGION_DEFAULT
  if [[ -z "$REGION" ]]; then
    def_region="$(rc_get REGION)"; [[ -z "$def_region" ]] && def_region="$REGION_DEFAULT"
    prompt_var REGION "Enter AWS region" "$def_region"
  fi

  [[ -n "$SERVER_ID" ]] || prompt_var SERVER_ID \
    "Enter Transfer Family server ID (e.g., s-xxxx)" "$(rc_get SERVER_ID)"

  [[ -n "$S3_BUCKET" ]] || prompt_var S3_BUCKET \
    "Enter S3 bucket for Transfer (e.g., sftp.nbs.example.gov)" "$(rc_get S3_BUCKET)"

  [[ -n "$CSV_FILE" ]] || prompt_var CSV_FILE \
    "Enter CSV file path (username,password)" "$(rc_get CSV_FILE)"

  if [[ -z "$ADMIN_MODE" ]]; then
    def_mode="$(rc_get ADMIN_MODE)"
    if [[ -n "$def_mode" ]]; then
      read -r -p "Admin mapping or User mapping? [admin/user] [$def_mode]: " ans || true
      ans="${ans:-$def_mode}"
    else
      read -r -p "Admin mapping or User mapping? [admin/user]: " ans || true
    fi
    case "${ans,,}" in
      admin|a) ADMIN_MODE="admin";;
      user|u) ADMIN_MODE="user";;
      *) die "Please choose 'admin' or 'user'.";;
    esac
    TOUCHED[ADMIN_MODE]=1
  fi

  if [[ "$ADMIN_MODE" == "user" && -z "$SITE" ]]; then
    prompt_var SITE \
      "Enter site name used in S3 path (e.g., example-prod)" "$(rc_get SITE)"
  fi

  # ROLE_ARN optional: prefer RC default; else compute
  if [[ -z "$ROLE_ARN" ]]; then
    role_from_rc="$(rc_get ROLE_ARN)"
    if [[ -n "$role_from_rc" ]]; then
      ROLE_ARN="$role_from_rc"
      # not touched unless user provided or we prompted (we didn't)
    else
      [[ "$ACCOUNT_NUM" =~ ^[0-9]{12}$ ]] || die "ACCOUNT_NUM must be 12 digits"
      ROLE_ARN="arn:aws:iam::${ACCOUNT_NUM}:role/sftp-simple2-full-bucket-role"
      # don't mark touched; computed defaults shouldn't overwrite RC unless user set/prompted
    fi
  fi
else
  [[ -n "$CSV_FILE" ]] || prompt_var CSV_FILE \
    "Enter CSV file path (username,password)" "$(rc_get CSV_FILE)"
fi

# For testing, prompt SFTP host/port with RC defaults if needed
if (( TEST_LOGINS == 1 || TEST_ONLY == 1 )); then
  if [[ -z "$SFTP_HOST" ]]; then
    def_host="$(rc_get SFTP_HOST)"; [[ -z "$def_host" ]] && def_host="sftp.nbs.example.gov"
    prompt_var SFTP_HOST "Enter SFTP host" "$def_host"
  fi
  if [[ -z "$SFTP_PORT" ]]; then
    def_port="$(rc_get SFTP_PORT)"; [[ -z "$def_port" ]] && def_port="22"
    prompt_var SFTP_PORT "Enter SFTP port" "$def_port"
  fi
fi

# ---------------------------------------------
# Preflight (only for secret create/update)
# ---------------------------------------------
if (( TEST_ONLY == 0 )); then
  have aws || die "aws CLI not found"
  have jq  || die "jq not found"
  [[ -f "$CSV_FILE" ]] || die "CSV file not found: $CSV_FILE"
  [[ -n "$SERVER_ID" ]] || die "SERVER_ID is required"
  [[ -n "$S3_BUCKET" ]] || die "S3_BUCKET is required"
  [[ "$ADMIN_MODE" == "admin" || "$ADMIN_MODE" == "user" ]] || die "ADMIN_MODE must be 'admin' or 'user'"

  if (( DRY_RUN )); then
    echo "[dry-run] Would validate IAM role and Transfer server exist"
  else
    aws_run iam get-role --role-name "$(basename "$ROLE_ARN")" >/dev/null || die "IAM role not found: $ROLE_ARN"
    aws_run transfer describe-server --server-id "$SERVER_ID" >/dev/null || die "Transfer server not found: $SERVER_ID"
  fi
fi

# ---------------------------------------------
# Build HomeDirectoryDetails **as STRING** (plaintext value)
# ---------------------------------------------
HOME_DETAILS_STR=""
if (( TEST_ONLY == 0 )); then
  if [[ "$ADMIN_MODE" == "admin" ]]; then
    HOME_DETAILS_STR=$(jq -cn --arg b "$S3_BUCKET" \
      '[{"Entry": "/", "Target": ("/"+$b+"/${Transfer:UserName}")}]')
  else
    [[ -n "$SITE" ]] || die "SITE is required for user mode"
    HOME_DETAILS_STR=$(jq -cn --arg b "$S3_BUCKET" --arg site "$SITE" \
      '[{"Entry": "/", "Target": ("/"+$b+"/"+$site+"/${Transfer:UserName}/incoming")}]')
  fi
fi

# Helper: intended payload (all fields stored as strings; HomeDirectoryDetails is a string)
intended_payload(){ # $1=password
  jq -n --arg pw "$1" --arg role "$ROLE_ARN" --arg details "$HOME_DETAILS_STR" \
    '{Password:$pw, Role:$role, HomeDirectoryType:"LOGICAL", HomeDirectoryDetails:$details}'
}

# Helper: summarize differences (treat details as string)
summarize_diff(){ # $1=current_json $2=intended_json
  local current="$1" intended="$2"
  for k in Password Role HomeDirectoryType; do
    local cur val
    cur="$(jq -r --arg k "$k" '.[$k] // ""' <<<"$current" 2>/dev/null || echo "")"
    val="$(jq -r --arg k "$k" '.[$k] // ""' <<<"$intended" 2>/dev/null || echo "")"
    if [[ "$cur" != "$val" ]]; then
      echo "    - $k differs"
    fi
  done
  local cur_det val_det
  cur_det="$(jq -cr '.HomeDirectoryDetails // "" | (if type=="string" then . else tostring end)' <<<"$current" 2>/dev/null || echo "")"
  val_det="$(jq -cr '.HomeDirectoryDetails // "" | (if type=="string" then . else tostring end)' <<<"$intended" 2>/dev/null || echo "")"
  if [[ "$cur_det" != "$val_det" ]]; then
    echo "    - HomeDirectoryDetails differs"
  fi
}

# CSV normalizer
clean_csv="$(mktemp)"
tr -d '\r' < "$CSV_FILE" > "$clean_csv"

# ---------------------------------------------
# Secret processing
# ---------------------------------------------
if (( TEST_ONLY == 0 )); then
  echo "Mode: $ADMIN_MODE   Overwrite: $OVERWRITE   Dry-run: $DRY_RUN"
  echo "Server: $SERVER_ID | Region: ${REGION:-default} | Profile: ${AWS_PROFILE:-default}"
  echo "Bucket: $S3_BUCKET | Site: ${SITE:-N/A}"
  echo "Role:   $ROLE_ARN"
  echo "CSV:    $CSV_FILE"
  echo

  while IFS=',' read -r username password rest; do
    [[ -z "${username// /}" ]] && continue
    [[ "${username,,}" == "username" ]] && continue
    [[ "${username:0:1}" == "#" ]] && continue
    if [[ -z "${password:-}" ]] ; then
      echo "Skipping '$username': empty password"
      continue
    fi

    secret_name="aws/transfer/${SERVER_ID}/${username}"
    echo "User: $username"
    intended="$(intended_payload "$password")"

    if aws_run secretsmanager describe-secret --secret-id "$secret_name" --no-cli-pager >/dev/null 2>&1; then
      echo "  → Secret exists: $secret_name"
      if current_json_raw="$(aws_run secretsmanager get-secret-value --secret-id "$secret_name" --no-cli-pager 2>/dev/null || true)"; then
        current="$(jq -r '.SecretString' <<<"$current_json_raw" 2>/dev/null || echo '{}')"
      else
        current="{}"
      fi

      diff_summary="$(summarize_diff "$current" "$intended" || true)"
      if [[ -z "$diff_summary" ]]; then
        echo "    No changes needed"
      else
        echo "  ! Differences detected:"
        echo "$diff_summary"
        if (( OVERWRITE )); then
          if (( DRY_RUN )); then
            echo "  [dry-run] Would overwrite secret"
          else
            aws_run secretsmanager put-secret-value \
              --secret-id "$secret_name" \
              --secret-string "$intended" \
              --no-cli-pager >/dev/null
            echo "    Overwritten (per --overwrite)"
          fi
        else
          echo "    Skipped overwrite (use --overwrite to apply)"
        fi
      fi
    else
      if (( DRY_RUN )); then
        echo "  [dry-run] Would create secret: $secret_name"
      else
        placeholder="$(jq -n --arg pw "$password" --arg role "$ROLE_ARN" \
          '{Password:$pw, Role:$role, HomeDirectoryType:"LOGICAL", HomeDirectoryDetails:"REPLACE_ME"}')"

        aws_run secretsmanager create-secret \
          --name "$secret_name" \
          --description "SFTP credentials for user ${username}" \
          --secret-string "$placeholder" \
          --tags "Key=TransferUser,Value=$username" \
          --no-cli-pager >/dev/null

        aws_run secretsmanager put-secret-value \
          --secret-id "$secret_name" \
          --secret-string "$intended" \
          --no-cli-pager >/dev/null

        echo "    Created $secret_name"
      fi
    fi
    echo
  done < "$clean_csv"
fi

# ---------------------------------------------
# SFTP Login Testing
# ---------------------------------------------
results_json="[]"
append_result_json(){ # $1=username $2=ok|fail $3=reason $4=ms
  local u="$1" r="$2" reason="$3" latency="$4"
  results_json="$(jq -c --arg u "$u" --arg r "$r" --arg reason "$reason" --argjson ms "$latency" \
    '. + [{"username":$u,"result":$r,"reason":$reason,"latency_ms":$ms}]' <<<"$results_json")"
}

if (( TEST_LOGINS == 1 || TEST_ONLY == 1 )); then
  have sshpass || die "sshpass not found (required for --test-logins/--test-only)"
  have sftp    || die "sftp not found (OpenSSH client)"
  have timeout || die "'timeout' command not found (coreutils) — required for testing"

  echo
  echo "=== SFTP Login Tests ==="
  echo "Host: $SFTP_HOST  Port: $SFTP_PORT  Timeout: $TIMEOUT"
  echo

  now_ms(){ date +%s%3N 2>/dev/null || (python3 - <<'PY'
import time; print(int(time.time()*1000))
PY
); }

  while IFS=',' read -r username password rest; do
    [[ -z "${username// /}" ]] && continue
    [[ "${username,,}" == "username" ]] && continue
    [[ "${username:0:1}" == "#" ]] && continue
    if [[ -z "${password:-}" ]]; then
      echo "Skipping test for '$username': empty password"
      append_result_json "$username" "fail" "empty_password" 0
      continue
    fi

    echo -n "Testing $username... "
    start="$(now_ms)"

    sftp_cmd=(
      sftp
      -o PreferredAuthentications=password
      -o PubkeyAuthentication=no
      -o StrictHostKeyChecking=no
      -o NumberOfPasswordPrompts=1
      -o ConnectTimeout=10
      -o ServerAliveInterval=5
      -o ServerAliveCountMax=2
      -P "$SFTP_PORT" "$username@$SFTP_HOST"
    )

    if output="$(sshpass -p "$password" timeout "$TIMEOUT" "${sftp_cmd[@]}" <<<"exit" 2>&1)"; then
      end="$(now_ms)"; ms=$(( end - start ))
      echo "Success (${ms}ms)"
      append_result_json "$username" "ok" "" "$ms"
    else
      end="$(now_ms)"; ms=$(( end - start ))
      reason="$(sed -n '1p' <<<"$output" | tr -d '\r' || true)"
      reason="${reason:-unknown_error}"
      echo "Failed (${ms}ms) — $reason"
      append_result_json "$username" "fail" "$reason" "$ms"
    fi
  done < "$clean_csv"

  if [[ -n "$REPORT_JSON" ]]; then
    printf '%s\n' "$results_json" > "$REPORT_JSON"
    echo "Saved JSON report: $REPORT_JSON"
  fi
  if [[ -n "$REPORT_CSV" ]]; then
    {
      echo "username,result,reason,latency_ms"
      jq -r '.[] | @csv' <<<"$results_json"
    } > "$REPORT_CSV"
    echo "Saved CSV report: $REPORT_CSV"
  fi
fi

# cleanup temp CSV
rm -f "$clean_csv"

# ---------------------------------------------
# Save RC for next run (preserve others; backup)
# ---------------------------------------------
save_rc_preserve
echo "Done."

