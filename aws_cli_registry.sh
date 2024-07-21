#!/bin/bash
# 우분투 환경에서 실행되는 것처럼 바궈야하네, 지금은 powershell이라서, 근데 되기는 하네 
powershell.exe -Command "Start-Process 'C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe'"

aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 306593213077.dkr.ecr.ap-northeast-2.amazonaws.com

docker build -t express .

docker tag express:latest 306593213077.dkr.ecr.ap-northeast-2.amazonaws.com/express:latest

docker push 306593213077.dkr.ecr.ap-northeast-2.amazonaws.com/express:latest


