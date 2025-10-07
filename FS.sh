#!/bin/bash

USER=beech1
IPS=("app1-aws.psfs.umbc.edu" "app2-aws.psfs.umbc.edu"  "appdev1-aws.psfs.umbc.edu" "appdev2-aws.psfs.umbc.edu" "fsdmo1-aws.psfs.umbc.edu" "fsdmo2-aws.psfs.umbc.edu" "fsdmo3-aws.psfs.umbc.edu" "web1-aws.psfs.umbc.edu" "web2-aws.psfs.umbc.edu" "webdev1-aws.psfs.umbc.edu" "webdev2-aws.psfs.umbc.edu")
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


