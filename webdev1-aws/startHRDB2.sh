aws ecr get-login-password --region us-east-1 --profile mai-ps-cicd  | docker login --username AWS --password-stdin 753987943454.dkr.ecr.us-east-1.amazonaws.com

#docker run --privileged --name hrdb2-webserver -e TZ=America/New_York -p 172.29.31.11:8447:8443 -p 172.29.31.11:8084:8080 -v /psoft/certs:/psoft/certs -v /devreports:/psoft/reports -d --env-file /psoft/Docker/HRDB2_docker.env -t 753987943454.dkr.ecr.us-east-1.amazonaws.com/ps-universal-webserver:85820

#docker run --privileged --name hrdb2-webserver -e TZ=America/New_York -p 172.29.31.11:8084:8080 -v /psoft/certs:/psoft/certs -v /devreports:/psoft/reports -d --env-file /psoft/Docker/HRDB2_docker.env -t 753987943454.dkr.ecr.us-east-1.amazonaws.com/ps-universal-webserver:85823

docker run --privileged --name hrdb2-webserver -e TZ=America/New_York -p 172.29.31.11:8084:8080 -v /psoft/certs:/psoft/certs -v /devreports:/psoft/reports -d --env-file /psoft/Docker/HRDB2_docker.env -t 753987943454.dkr.ecr.us-east-1.amazonaws.com/ps-universal-webserver:85923

