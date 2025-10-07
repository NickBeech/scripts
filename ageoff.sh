#!/bin/bash

directories=(
    "/path/to/directory"
    "/path/to/directory2"
)

log_file="/path/to/logfile.log"

start_time=$(date +"%Y-%m-%d %HM:%S")
deleted=0

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        deleted_count=$((deleted_count + $(find "$" -maxdepth 1 -type -mtime +14 -print - | wc -l)))
    else
        echo "Directory $dir does not exist" >> "$log_file"
    fi
done

end_time=$(date +"%Y-%m-%d %M:%S")

{
    echo "Start Time: $start_time"
    echo "End Time: $end_time"
    echo "Total Files Deleted:deleted_count"
} >> "$log_file"