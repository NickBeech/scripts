#!/bin/bash

log_file="rsync_script.log"

# Check if a file is open another process using lsof
is_file_open() {
 local file_path="$1"    
 if lsof "$file_path" > /dev/null 2>&1;
        return 0
    else
        return 1
    fi
}


# Change the owner and group of a file if do not match the specified user and group

change_owner_group_if_needed() {
    local file_path="$1"
    local user="$2"
 local group="$3"
    uid
    local gid

    uid=$(id -u "$user")
    gid=$(id -g "$group")

    current_uid=$(stat -c "%" "$file")
    current_gid=$(stat -c "%g" "$file_path")

    if [ "$current_uid" -ne "$uid" ] || ["current_gid" -ne "$gid" ]; then
        chown "$user:$group" "$file_path"
    fi
}


# Synchronize files from the source directory to the destination directory using rsync
safe_rsync() {
    local src_dir="$1"
    local dest_dir="$2"
    local pattern="$3"
    local remove_source_files="$4"

    mkdir -p "$dest_dir"

    local files_to_sync=()
    local_to_remove=()

    for item in "$src_dir"/*; do
        if [ -f "$item" ]; then
            if [ -n "$pattern" ] && [[ ! "$(basename "$item") =~pattern ]]; then
                continue
            fi
            if ! is_file_open "$item"; then
                files_to_sync+=("$item")
                if [ "$remove_source_files" = true ]; then
                    files_to_remove+=("$item")
                fi
            else
                echo "Skipping $(basename "$item"), as it's currently open by another process." | tee -a "$log_file"
            fi
        fi
    done    if [ "${#files_to_sync[@]}" -gt 0 ]; then
 echo "Syncing files from $src_dir to $dest_dir..." | tee -a "$log_file"
        rsync -avupdate "${files_to_sync[@]}" "$dest_dir/"

        if [[ "$dest" == *"/informatica/"* ]]; then
            for item in "$dest_dir"/*; do
                if [ -f "$item ]; then
                    change_owner_group_if_needed "$item" "informatica_ps" "csdevl"
                fi
            done
        fi

        if [ "$remove_source_files" = true ]; then            for file_path in "${files_to_remove[@]}"; do
                echo "Removing source file: $file_path" | tee -alog_file"
                rm "$file_path"
            done
        fi
    else
        echo "No files to sync from $src_dir to $dest_dir." | tee -a "$log_file"
    fi
}


# Function calls

safe_rsync "/p/hrtransfer/csprd_interfaces/informatica/inbound/SFDC_UG/Unrecognizediles" \
           "/psoft/hrtransfer/csprd_interfaces/in/SFDC_UG/Unrecognized_Files"

safe_rsync "/psoft/hrtransfer/csprd_interfaces/informatica/inbound/uadm" \
 "/psoft/hrtransfer/csprd_interfaces/in/uadm"

safe_rsync "/psoft/hrtransfer/csprd_interfaces/informatica/inbound/grad" \
           "/psoft/hrtransfer/csprd_interfaces/in/grad"

safe_rsync "/psoft/hrtransfer/csprd_interfaces/in/SFDC_UG" \
           "/psoft/hrtransfer/csprd_interfaces/informatica/in/SFDC_UG" \
           "" true

safe_r "/psofttransfer/csprd_interfaces/out/grad" \
           "/psoft/hrtransfer/csprd_interfaces/informatica/outboundgrad" \
           "CNet_GRAD*"