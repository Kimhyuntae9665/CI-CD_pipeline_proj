#!/bin/bash

powershell.exe -Command "Start-Process 'C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe'"

aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 306593213077.dkr.ecr.ap-northeast-2.amazonaws.com

docker build -t express .

docker tag express:latest 306593213077.dkr.ecr.ap-northeast-2.amazonaws.com/express:latest

docker push 306593213077.dkr.ecr.ap-northeast-2.amazonaws.com/express:latest


