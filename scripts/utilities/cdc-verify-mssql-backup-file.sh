#!/bin/bash

# this script will use sqlcmd to verify a backup.  It is a bash script that can be run on linux so as 
# not to require a GUI environment and associated network access, it can be run "standalone" with just a shell
# have not tested from cloudshell
# it is not really standalone because it requires a working MS SQL server


# Default settings
BACKUP_DIR="/var/opt/mssql/backup"  # Directory containing backup files
SQL_SERVER="localhost"              # Default SQL Server hostname or IP
SQL_USER="sa"                       # Default SQL Server username
SQL_PASSWORD="YourPassword"         # Default SQL Server password
SQL_DATABASE="master"               # Default database (not required for RESTORE commands)
LOG_FILE=""                          # Log file (set to "" to disable logging)
CHECK_HEADERS=false
CHECK_FILELIST=false

# Function to log messages (if logging is enabled)
log_message() {
    if [ -n "$LOG_FILE" ]; then
        echo "$1" | tee -a "$LOG_FILE"
    else
        echo "$1"
    fi
}

# Usage function
usage() {
    echo "Usage: $0 [-h] [-f] [-l <log_file>] [-s <server>] [-u <user>] [-p <password>] [-d <database>]"
    echo "  -h   Enable HEADERSONLY check"
    echo "  -f   Enable FILELISTONLY check"
    echo "  -l   Specify log file (optional)"
    echo "  -s   SQL Server instance (default: localhost)"
    echo "  -u   SQL username (default: sa)"
    echo "  -p   SQL password (default: YourPassword)"
    echo "  -d   SQL database name (default: master)"
    exit 1
}

# Parse command-line options
while getopts ":hfl:s:u:p:d:" opt; do
    case ${opt} in
        h ) CHECK_HEADERS=true ;;
        f ) CHECK_FILELIST=true ;;
        l ) LOG_FILE="$OPTARG" ;;
        s ) SQL_SERVER="$OPTARG" ;;
        u ) SQL_USER="$OPTARG" ;;
        p ) SQL_PASSWORD="$OPTARG" ;;
        d ) SQL_DATABASE="$OPTARG" ;;
        \? ) usage ;;
    esac
done

# Start Logging (if enabled)
if [ -n "$LOG_FILE" ]; then
    echo "Backup Verification Log - $(date)" > "$LOG_FILE"
    echo "Checking backup files in: $BACKUP_DIR" | tee -a "$LOG_FILE"
    echo "SQL Server: $SQL_SERVER, User: $SQL_USER, Database: $SQL_DATABASE" | tee -a "$LOG_FILE"
    echo "Options - HEADERSONLY: $CHECK_HEADERS, FILELISTONLY: $CHECK_FILELIST" | tee -a "$LOG_FILE"
    echo "----------------------------------------" | tee -a "$LOG_FILE"
fi

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    log_message "Error: Backup directory '$BACKUP_DIR' does not exist."
    exit 1
fi

# Check if there are any .bak files
BAK_FILES=("$BACKUP_DIR"/*.bak)
if [ ! -e "${BAK_FILES[0]}" ]; then
    log_message "No backup files found."
    exit 0
fi

# Loop through all .bak files in the directory
for BACKUP_FILE in "$BACKUP_DIR"/*.bak; do
    log_message "Checking: $BACKUP_FILE"

    # Run RESTORE VERIFYONLY and capture output
    VERIFY_OUTPUT=$(sqlcmd -S "$SQL_SERVER" -U "$SQL_USER" -P "$SQL_PASSWORD" -d "$SQL_DATABASE" -Q "RESTORE VERIFYONLY FROM DISK = '$BACKUP_FILE'" 2>&1)
    if [ $? -eq 0 ]; then
        RESULT="VALID - $(echo "$VERIFY_OUTPUT" | tr -d '\n' | sed 's/  */ /g')"
    else
        RESULT="INVALID - $(echo "$VERIFY_OUTPUT" | tr -d '\n' | sed 's/  */ /g')"
    fi
    log_message "$BACKUP_FILE : $RESULT"

    # Run HEADERSONLY check if enabled
    if [ "$CHECK_HEADERS" = true ]; then
        HEADER_OUTPUT=$(sqlcmd -S "$SQL_SERVER" -U "$SQL_USER" -P "$SQL_PASSWORD" -d "$SQL_DATABASE" -Q "RESTORE HEADERONLY FROM DISK = '$BACKUP_FILE'" 2>&1)
        log_message "HEADERSONLY: $(echo "$HEADER_OUTPUT" | tr -d '\n' | sed 's/  */ /g')"
    fi

    # Run FILELISTONLY check if enabled
    if [ "$CHECK_FILELIST" = true ]; then
        FILELIST_OUTPUT=$(sqlcmd -S "$SQL_SERVER" -U "$SQL_USER" -P "$SQL_PASSWORD" -d "$SQL_DATABASE" -Q "RESTORE FILELISTONLY FROM DISK = '$BACKUP_FILE'" 2>&1)
        log_message "FILELISTONLY: $(echo "$FILELIST_OUTPUT" | tr -d '\n' | sed 's/  */ /g')"
    fi
done

log_message "Backup verification completed."

