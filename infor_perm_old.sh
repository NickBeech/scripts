#!/bin/bash

# Configuration Variables
directory="/psoft/hrtransfer/csprd_interfaces/informatica/outbound/grad/"
old_owner="csprd"               # Current owner to look for
old_group="ps"                  # Current group to look for
new_owner="informatica_ps"      # New owner to set
new_group="csdevl"              # New group to set

# Log file base path (without the date part)
log_base="/informatica_scripts/info_perm_log"

# Get the current date in the format YYYY-MM-DD
current_date=$(date +%F)

# Construct the full log file path with the current date
log_file="${log_base}.txt"  # Always use a singular log file (info_perm_log.txt)

# Check if it's after midnight (00:00:01 or later)
current_time=$(date +%H%M%S)

# Ensure the directory exists
if [ ! -d "$directory" ]; then
    echo "$(date) - ERROR: Directory '$directory' does not exist." >> "$log_file"
    exit 1
fi

# Start logging the cron job run
echo "$(date) - Change Owner/Group Script Started" >> "$log_file"
echo "Searching for files owned by $old_owner:$old_group to change to $new_owner:$new_group" >> "$log_file"
echo "" >> "$log_file"

# Initialize a counter to track the number of files changed
files_changed=0

# Find all files in the directory matching the old_owner and old_group
# and change the owner/group to the new_owner:new_group
find "$directory" -type f -exec stat --format="%n %U %G" {} \; | while read file owner group; do
    if [[ "$owner" == "$old_owner" && "$group" == "$old_group" ]]; then
        # Change ownership of the file
        chown "$new_owner:$new_group" "$file"
        
        # Increment the counter for each file that is changed
        ((files_changed++))
    fi
done

# Log the number of files that were changed
echo "$(date) - Changed $files_changed files from $old_owner:$old_group to $new_owner:$new_group" >> "$log_file"

# Log the end time of the script
echo "$(date) - Change Owner/Group Script Ended" >> "$log_file"
echo "" >> "$log_file"


#!/bin/bash

# Configuration Variables
directory="/psoft/hrtransfer/csprd_interfaces/informatica/outbound/grad/"         # Directory for files
dir_to_change="/psoft/hrtransfer/csprd_interfaces/informatica/inbound/SFDC_UG/"  # Directory to change owner
old_owner="csprd"               # Current owner to look for
old_group="ps"                  # Current group to look for
new_owner="informatica_ps"      # New owner to set
new_group="csdevl"              # New group to set

# Log file base path
log_base="/informatica_scripts/info_perm_log"
log_file="${log_base}.txt"  # Always use a singular log file (info_perm_log.txt)

# Ensure the directories exist
if [ ! -d "$directory" ]; then
    echo "$(date) - ERROR: Directory '$directory' does not exist." >> "$log_file"
    exit 1
fi

if [ ! -d "$dir_to_change" ]; then
    echo "$(date) - ERROR: Directory '$dir_to_change' does not exist." >> "$log_file"
    exit 1
fi

# Start logging the cron job run
echo "$(date) - Change Owner/Group Script Started" >> "$log_file"
echo "Processing files in '$directory' to change ownership and permissions" >> "$log_file"
echo "Also updating ownership of directory '$dir_to_change' user to $new_owner (group remains unchanged)" >> "$log_file"
echo "" >> "$log_file"

# Initialize counters
files_changed=0
files_not_640=0

# Change ownership of the directory itself (only user, not group)
dir_owner=$(stat --format="%U" "$dir_to_change")
dir_group=$(stat --format="%G" "$dir_to_change")

if [[ "$dir_owner" == "$old_owner" && "$dir_group" == "$old_group" ]]; then
    # Change only the user ownership of the directory (keeping the group unchanged)
    chown "$new_owner" "$dir_to_change"
    echo "$(date) - Changed ownership of directory '$dir_to_change' user from $old_owner to $new_owner" >> "$log_file"
fi

# Process files in the directory to change ownership and permissions
find "$directory" -type f | while read -r file; do
    # Get file ownership and permissions
    owner=$(stat --format="%U" "$file")
    group=$(stat --format="%G" "$file")
    perms=$(stat --format="%a" "$file")

    # Change ownership if the file matches the old owner and group
    if [[ "$owner" == "$old_owner" && "$group" == "$old_group" ]]; then
        chown "$new_owner:$new_group" "$file"
        chmod 640 "$file"
        echo "$(date) - Changed ownership and permissions of '$file' to $new_owner:$new_group and rw-r------" >> "$log_file"
        ((files_changed++))
    fi

    # Check and correct permissions if they are not 640
    if [ "$perms" -ne 640 ]; then
        chmod 640 "$file"
        echo "$(date) - Fixed permissions of '$file' to rw-r------ (was $perms)" >> "$log_file"
        ((files_not_640++))
    fi
done

# Log summary
echo "$(date) - Changed ownership and permissions for $files_changed files" >> "$log_file"
echo "$(date) - Fixed permissions for $files_not_640 files to rw-r------" >> "$log_file"

# End script
echo "$(date) - Change Owner/Group Script Ended" >> "$log_file"
echo "" >> "$log_file"
