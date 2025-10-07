#!/bin/bash

# Full paths to commands (in case cron environment doesn't have the usual paths)
RSYNC="/usr/bin/rsync"
DATE="/bin/date"
LOG_DIR="/var/log/delete_old_files_logs"
LOCK_FILE="/var/run/delete_old_files.lock"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Get the current date in MMMDDYYYY format
LOG_DATE=$($DATE +"%b%d%Y")  # Example: Nov122024

# Create a log file for today's date
LOG_FILE="$LOG_DIR/delete_old_files_$LOG_DATE.log"

# Check if another instance is running using a lockfile
if [ -f "$LOCK_FILE" ]; then
    echo "$($DATE) - ERROR: Script is already running." >> "$LOG_FILE"
    exit 1
fi
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# Hardcoded directories (no CLI input required)
TARGET_DIR="/psoft/exports/CampusCE"
SOURCE_DIR="/psoft/hrtransfer/csprd_interfaces/in/campusce"

# Check for --dry-run flag
DRY_RUN=false
for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
        DRY_RUN=true
        echo "Dry run mode enabled: No files will be deleted." >> "$LOG_FILE"
    fi
done

# Verify the directories exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "$($DATE) - ERROR: Target directory '$TARGET_DIR' does not exist." >> "$LOG_FILE"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "$($DATE) - ERROR: Source directory '$SOURCE_DIR' does not exist." >> "$LOG_FILE"
    exit 1
fi

# Start logging sync and cleanup process
echo "$($DATE) - Starting cleanup and sync process for source and target directories." >> "$LOG_FILE"

# Find and delete old files from the source directory
find "$SOURCE_DIR" -maxdepth 1 -type f -mtime +14 | while read -r src_file; do
    file_name=$(basename "$src_file")
    if [ -f "$TARGET_DIR/$file_name" ]; then
        echo "$($DATE) - Deleting file from source directory: $src_file" >> "$LOG_FILE"
        if [ "$DRY_RUN" = false ]; then
            rm -f "$src_file"
        else
            echo "$($DATE) - DRY-RUN: Would delete file from source: $src_file" >> "$LOG_FILE"
        fi
    fi
done

# Rsync from source to target after cleanup
echo "$($DATE) - Syncing files from '$SOURCE_DIR' to '$TARGET_DIR'..." >> "$LOG_FILE"
if [ "$DRY_RUN" = false ]; then
    if ! $RSYNC -av --delete "$SOURCE_DIR/" "$TARGET_DIR/"; then
        echo "$($DATE) - ERROR: Rsync failed." >> "$LOG_FILE"
        exit 1
    fi
else
    echo "$($DATE) - DRY-RUN: Skipping rsync (no files will be copied or deleted)." >> "$LOG_FILE"
fi

echo "$($DATE) - Cleanup and sync complete." >> "$LOG_FILE"
exit 0
