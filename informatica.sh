#!/bin/bash

USER=beech1
IPS=("informatica1-v1.umbc.edu" "informatica2-v1.umbc.edu" "informatica3-v1.umbc.edu" "informatica4-v1.umbc.edu" "informatica5-v1.umbc.edu")
for ip in "${IPS[@]}"; do
    echo "Running ssh-copy-id $USER@$ip"
    ssh-copy-id -i ~/.ssh/id_rsa "$USER@$ip"

    # Check if ssh-copy-id was successful
    if [ $? -eq 0 ]; then
        echo "ssh-copy-id successful for $USER@$ip"
    else
        echo "ssh-copy-id failed for $USER@$ip"
    fi

    echo
done