#!/bin/bash

# GitHub 정보 설정
REPO="Kimhyuntae9665/express_infelearn"
WORKFLOW_NAME="TestAndDeploy.yml"
TOKEN=$TOKEN  # 환경 변수에서 토큰을 가져옴

# GitHub API를 사용하여 워크플로우 상태 확인
response=$(curl -s -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW_NAME/runs?status=completed&per_page=1")

# 최신 워크플로우의 상태 가져오기
workflow_status=$(echo $response | grep -o '"conclusion": "[^"]*' | grep -o '[^"]*$')

# 워크플로우 상태 출력 (선택 사항)
echo "Latest workflow status: $workflow_status"

# 워크플로우가 성공적으로 완료된 경우 로컬 스크립트 실행
if [ "$workflow_status" == "success" ]; then
    echo "Workflow succeeded. Executing local script... Success"
    ./aws_cli_registry.sh
else
    echo "Workflow did not succeed. Exiting..."
fi
