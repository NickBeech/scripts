#!/bin/bash

# Configurable Parameters
SOURCE_DIR="/path/to/source/directory/"
DEST_DIR="/path/to/destination/directory/"
LOG_FILE="/path/to/logfile.log"
MAX_LOG_SIZE=1048576  # 1 MB
AGE_THRESHOLD=14       # Days

# Timestamp function
log_timestamp() {
    echo "$(date +"%Y-%m-%d %H:%:%S")"
}

# Rotate logs if they exceed max size
rotate_logs() {
    if [[ -f "$LOG_FILE" && $(stat -c%s "$LOG_FILE") -ge $MAX_LOG_SIZE ]]; then
        mv "$LOG_FILE" "$LOG_FILE.old"
        echo "$(log_timestamp) Log file rotated." >> "$LOG_FILE"
    fi
}

# Check if directory exists
check_directory() {
    if [[ ! -d "$1" ]]; then
        echo "$(log_timestamp) ERROR: Directory $1 does not exist." >> "$LOG_FILE"
        exit 1
    fi
}

# Remove files older than AGE_THRESHOLD without prompting
remove_old_files() {
    local dir="$1"
    local file_count=$(find "$dir" -type f -mtime +"$AGE_THRESHOLD" | wc -l)

    if [[ $file_count -gt 0 ]]; then
        echo "$(log_timestamp) WARNING: Removing $file_count files older than $AGE_THRESHOLD days from $dir." >> "$LOG_FILE"
        
        # Find and log files before deletion
        files_to_remove=$(find "$dir" -type f -mtime +"$AGE_THRESHOLD")
        if [[ -n "$files_to_remove" ]]; then
            echo "$files_to_remove" >> "$LOG_FILE"
            echo "$(log_timestamp) Removing the following files from $dir:" >> "$LOG_FILE"
            echo "$files_to_remove" >> "$LOG_FILE"

            # Attempt to remove files and log errors if any
            if ! find "$dir" -type f -mtime +"$AGE_THRESHOLD" -exec rm -f {} \; 2>> "$LOG_FILE"; then
                "$(log_timestamp) ERROR: Error occurred while removing files from $dir." >> "$LOG_FILE"
            else
                echo "$(log_timestamp) Removed files older than $AGE_THRESHOLD days from $dir." >> "$LOG_FILE"
            fi
        else
            echo "$(log_timestamp) No files to remove from $dir." >> "$LOG_FILE"
        fi
    else
        echo "$(log_timestamp) No files older than $AGE_THRESHOLD days found in $dir." >> "$LOG_FILE"
    fi
}

# Check if source and destination directories exist
check_directory "$SOURCE_DIR"
check_directory "$DEST_DIR"

# Remove old files from source and destination
remove_old_files "$SOURCE_DIR"
remove_old_files "$DEST_DIR"

# Rsync command
rotate_logs
if ! rsync -av --delete "$SOURCE_DIR" "$DEST_DIR" >> "$LOG_FILE" 2>&1; then
    echo "$(log_timestamp) ERROR: Sync failed! Check rsync output above for details." >> "$LOG_FILE"
else
    echo "$(log_timestamp) Sync completed successfully." >> "$LOG_FILE"
fi