#!/bin/bash

desired_owner_group="informatica_ps:csdevl"

directories=(
  "/psoft/hrtransfer/csprd_interfaces/informatica/outbound/grad/"
  "/psoft/hrtransfer/csprd_interfaces/informatica/inbound/SFDC_UG/"
)

files_modified=0

log_base="/informatica_scripts/info_perm_log"
log_file="${log_base}.txt"  

for dir in "${directories[@]}"; do
  files=("$dir"/*)
  for file in "${files[@]}"; do
    current_owner_group=$(stat -c '%U:%G' "$file")
    if [ "$current_owner_group" != "$desired_owner_group" ]; then
      chown "$desired_owner_group" "$file"
      ((files_modified++))
    fi
  done
done

echo "Modified permissions for $files_modified files" >> "$log_file"