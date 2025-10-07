#!/bin/bash

# Full paths to commands (in case cron environment doesn't have the usual paths)
RSYNC="/usr/bin/rsync"
DATE="/bin/date"
LOG_DIR="/psoft/csprd/scripts/"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Get the current date in MMMDDYYYY format
LOG_DATE=$($DATE +"%b%d%Y")  # Example: Nov122024

# Create a log file for today's date
LOG_FILE="$LOG_DIR/delete_old_files_$LOG_DATE.log"

# Directories
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
echo "$($DATE) - Starting sync and cleanup for source and target directories." >> "$LOG_FILE"

# Sync files from the source directory to the target directory using rsync
echo "$($DATE) - Syncing files from '$SOURCE_DIR' to '$TARGET_DIR'..." >> "$LOG_FILE"
$RSYNC -av --delete "$SOURCE_DIR/" "$TARGET_DIR/" >> "$LOG_FILE" 2>&1

# Find files older than 14 days in the source directory and check if they exist in the target directory
find "$SOURCE_DIR" -maxdepth 1 -type f -mtime +14 | while read -r src_file; do
    # Extract the filename (without path)
    file_name=$(basename "$src_file")

    # Check if the file exists in the target directory
    if [ -f "$TARGET_DIR/$file_name" ]; then
        # Log the deletion process
        echo "$($DATE) - File '$file_name' found in both source and target. Proceeding to delete." >> "$LOG_FILE"
        
        if [ "$DRY_RUN" = false ]; then
            # Delete the file from the source and target directories
            echo "$($DATE) - Deleting file from source directory: $src_file" >> "$LOG_FILE"
            echo "$($DATE) - Deleting file from target directory: $TARGET_DIR/$file_name" >> "$LOG_FILE"

            rm -f "$src_file"
            rm -f "$TARGET_DIR/$file_name"
        else
            # Dry run, just log the files that would be deleted
            echo "$($DATE) - DRY-RUN: Would delete file from source: $src_file" >> "$LOG_FILE"
            echo "$($DATE) - DRY-RUN: Would delete file from target: $TARGET_DIR/$file_name" >> "$LOG_FILE"
        fi
    fi
done

# Log completion message
echo "$($DATE) - Cleanup complete." >> "$LOG_FILE"

# Optional: If you want to add a specific exit code for success or failure
exit 0
