#!/bin/bash

USER=beech1
IPS=("app1-aws.pshr.umbc.edu" "app2-aws.pshr.umbc.edu" "appdev1-aws.pshr.umbc.edu" "appdev2-aws.pshr.umbc.edu" "web1-aws.pshr.umbc.edu" "web2-aws.pshr.umbc.edu" "webdev1-aws.pshr.umbc.edu" "webdev2-aws.pshr.umbc.edu")
for ip in "${IPS[@]}"; do
    echo "Running ssh-copy-id $USER@$ip"
    ssh-copy-id -i ~/.ssh/id_rsa.pub "$USER@$ip"

    # Check if ssh-copy-id was successful
    if [ $? -eq 0 ]; then
        echo "ssh-copy-id successful for $USER@$ip"
    else
        echo "ssh-copy-id failed for $USER@$ip"
    fi

    echo
done
