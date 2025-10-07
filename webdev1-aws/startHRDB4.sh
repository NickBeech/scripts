#docker run --privileged --name hrdb4-webserver -e TZ=America/New_York -p 172.29.31.11:8449:8443 -p 172.29.31.11:8086:8080 -v /psoft/certs:/psoft/certs -v /devreports:/psoft/reports -d --env-file /psoft/Docker/HRDB4_docker.env -t 753987943454.dkr.ecr.us-east-1.amazonaws.com/ps-universal-webserver:85820

docker run --privileged --name hrdb4-webserver -e TZ=America/New_York -p 172.29.31.11:8086:8080 -v /psoft/certs:/psoft/certs -v /devreports:/psoft/reports -d --env-file /psoft/Docker/HRDB4_docker.env -t 753987943454.dkr.ecr.us-east-1.amazonaws.com/ps-universal-webserver:85923


