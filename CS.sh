#!/bin/bash

USER=beech1
IPS=("app1-aws.pscs.umbc.edu" "app2-aws.pscs.umbc.edu" "app3-aws.pscs.umbc.edu" "app4-aws.pscs.umbc.edu" "app5-aws.pscs.umbc.edu" "app6-aws.pscs.umbc.edu" "appdev1-aws.pscs.umbc.edu" "appdev2-aws.pscs.umbc.edu" "webdev1-aws.pscs.umbc.edu" "webdev2-aws.pscs.umbc.edu" "web1-aws.pscs.umbc.edu" "web2-aws.pscs.umbc.edu" "web3-aws.pscs.umbc.edu" "web4-aws.pscs.umbc.edu")
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
