#!/bin/bash

# GitHub 정보 설정
REPO="Kimhyuntae9665/express_infelearn"
WORKFLOW_NAME="TestAndDeploy.yml"
TOKEN=$TOKEN  # 환경 변수에서 토큰을 가져옴

# GitHub API를 사용하여 워크플로우 상태 확인
response=$(curl -s -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW_NAME/runs?status=completed&per_page=1")

# 워크플로우의 상태 가져온다 
workflow_status=$(echo $response | grep -o '"conclusion": "[^"]*' | grep -o '[^"]*$')

# 워크플로우 상태 출력 (선택 사항)
echo "Latest workflow status: $workflow_status"

# 워크플로우가 성공적으로 완료된 경우 aws_cli를 이용 registry에 docker image를 올리는 script를 진행 
if [ "$workflow_status" == "success" ]; then
    echo "Workflow succeeded. Executing local script... Success"
    chmod +x ./aws_cli_registry.sh 
    ./aws_cli_registry.sh
else
    echo "Workflow did not succeed. Exiting..."
fi
