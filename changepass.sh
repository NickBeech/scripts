#/bin/bash

# Variables (replace with actual username and password)
username="informatica_ps"
new_password="" ##Password to change to

# Function to securely change password
change_password() {
    local username="$1"
    local password="$2"
    
    # Change the password using sudo, redirect stdout to /dev/null
    # and leave stderr (errors) to be displayed
    if echo "$username:$password" | sudo chpasswd >/dev/null; then
        echo "Password for user '$username' changed successfully."
    else
        echo "Failed to change password for user '$username'."
        exit 1
    fi
}

# Call function to change password
change_password "$username" "$new_password"
