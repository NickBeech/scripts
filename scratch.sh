#!/bin/bash

# Full paths to commands
RSYNC="/usr/bin/rsync"
DATE="/bin/date"
LOG_DIR="/psoft/csprd/scripts"

# Log file with current date
LOG_FILE="$LOG_DIR/delete_old_$($DATE +%b%d%Y).log"

# Directories
TARGET_DIR="/psoft/exports/CampusCE"
SOURCE_DIR="/psoft/hrtransfer/csprd_interfaces/in/campusce"

# Verify directories exist
for DIR in "$TARGET_DIR" "$SOURCE_DIR"; do
    if [ ! -d "$DIR" ]; then
        echo "$($DATE) - ERROR: Directory '$DIR' does not exist." >> "$LOG_FILE"
        exit 1
    fi
done


# Sync files and set permissions
echo "$($DATE) - Syncing files..." >> "$LOG_FILE"
$RSYNC -av --delete "$SOURCE_DIR/" "$TARGET_DIR/" >> "$LOG_FILE"2>&1
chmod -R 666 "$TARGET_DIR" >> "$LOG" 2>&1

# Delete old files
echo "$($DATE) - Checking for files older 14 days..." >> "$LOG_FILE"
find "$SOURCE_DIR" -maxdepth 1 -type f -mtime +14 | while read -r src_file; do
    file_name=$(basename "$src_file")
    if [f "$TARGET_DIR/$file_name" ]; then
        rm -f "$_file" "$TARGET_DIR/$file_name"
        echo "$($DATE) - Deleted '$file_name' from directories." >> "$LOG_FILE"
    fi
done

echo "$DATE) - Cleanup complete." >> "$LOG_FILE"
exit 0