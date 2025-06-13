# SFTP Transfer Automation Script

This Bash script automates the transfer of files from a **source SFTP server** to a **destination SFTP server**, preventing duplicate downloads, supporting subdirectory mapping, and offering flexible configuration options.  
It uses `lftp` for reliable, scriptable SFTP operations.

---

## Features

- **Prevents Duplicate Downloads:** Keeps a log of downloaded files and only transfers new ones.
- **Staging Directory:** Downloads files to a local staging area before uploading.
- **Subdirectory Mapping:** Supports mapping file name prefixes to destination subdirectories.
- **Modes:**  
  - *Additive (default):* Never deletes files on the destination.
  - *Sync (-s flag):* Deletes files on the destination that don’t exist locally.
- **Interactive Configuration:** Prompts for SFTP credentials and paths.
- **Flags for Dry-Run, Debug, and More:** See [Usage](#usage).
- **Easy Configuration File:** Stores SFTP credentials and optional mapping logic in `.sftp_transfer.rc`.

---

## Requirements

- **Bash** (v4+ recommended)
- **lftp**  
  Install via your package manager, e.g.  
  `sudo apt-get install lftp`  
  `brew install lftp`

---

## Quick Start

1. **Download the Script**

   Save the script as `sftp_transfer.sh` and make it executable:
   ```bash
   chmod +x sftp_transfer.sh
   ```

2. **First-Time Setup**

   The script will prompt you to configure SFTP details if no `.sftp_transfer.rc` file is found:
   ```bash
   ./sftp_transfer.sh -c
   ```

3. **Run the Transfer**

   ```bash
   ./sftp_transfer.sh
   ```

4. **(Optional) Set Up Subdirectory Mappings**

   After initial configuration, edit `.sftp_transfer.rc` to map file name prefixes to subdirectories:
   ```bash
   export SUBDIR_MAPPINGS=(
     "PREFIX1:subdir1"
     "PREFIX2:subdir2"
   )
   ```
   Files not matching any mapping will go to `unsorted`.

---

## Usage

```bash
./sftp_transfer.sh [options]
```

**Options:**
- `-n` : Dry run (show what would be done, but don’t transfer files)
- `-d` : Debug mode (verbose output)
- `-c` : Configure or update SFTP credentials and paths
- `-k` : Keep the staging directory (do not clean before run)
- `-s` : Sync mode (allow deletes on the destination to match staging)
- `-h` : Show help

**Examples:**

- Configure SFTP credentials:
  ```bash
  ./sftp_transfer.sh -c
  ```

- Dry-run with debug output:
  ```bash
  ./sftp_transfer.sh -n -d
  ```

- Sync mode (mirror source, including deletions):
  ```bash
  ./sftp_transfer.sh -s
  ```

---

## Configuration File: `.sftp_transfer.rc`

Environment variables are exported here.  
Sample contents:

```bash
export SRC_SFTP_USER="sourceuser"
export SRC_SFTP_PASS="sourcepass"
export SRC_SFTP_HOST="source.host.com"
export SRC_SFTP_PATH="/source/path"

export DST_SFTP_USER="destuser"
export DST_SFTP_PASS="destpass"
export DST_SFTP_HOST="dest.host.com"
export DST_SFTP_PATH="/dest/path"

# Optional: Subdirectory mappings (prefix:subdir)
export SUBDIR_MAPPINGS=(
  "LabA:lab_a"
  "LabB:lab_b"
)
```

---

## Log Files and Staging

- **Staging Directory:**  
  All files are downloaded to `./sftp_staging/` (by default).
- **Download Log:**  
  Downloaded file names are tracked in `./downloaded.log` to avoid duplicates.

---

## Notes and Best Practices

- The script is additive by default; destination files are **never deleted** unless `-s` is given.
- Credentials are stored in a local file (`.sftp_transfer.rc`) — secure this file!
- Subdirectory mapping is based on file name **prefixes**.
- For automation, use the flags and pre-populate `.sftp_transfer.rc` as needed.

---

## Troubleshooting

- **lftp not found:**  
  Install it using your system’s package manager.
- **Permissions:**  
  Ensure the script is executable and you have write permissions in the working directory.
- **Duplicate transfers:**  
  If you need to re-download a file, remove it from `downloaded.log`.

---

