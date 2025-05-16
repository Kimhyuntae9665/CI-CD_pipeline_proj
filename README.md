먼저 부분적으로 
aws_cli_registry.sh을 실행하면, aws ECR로 image가 로드된다 
![image](https://github.com/user-attachments/assets/6ff55fc3-9d1e-4233-9de6-67c7e4e00c3e)
그 다음에 aws ecs로 가서 , 클러스터를 만들고 aws ecs에서 테스크 정의를 해준다 , 거기에서 로드된 ECR의 image를 사용한다 
그리고 클러스터에서 ![image](https://github.com/user-attachments/assets/d9ac62ea-a53f-4972-ab28-161e07a7964b)
이걸로 생성하는건데 , 지금 load balancersl , 네트워크니 잘 설정이 안되 있어서 잘 안되네 
![image](https://github.com/user-attachments/assets/3705eaae-785b-422c-ba43-0b05e22057ce)


![image](https://github.com/user-attachments/assets/1012d3e1-bd5c-4e77-8e62-a92e745f09d7)
![image](https://github.com/user-attachments/assets/df7813b1-14af-4229-9e8b-8ecc94ffbca6)

![image](https://github.com/user-attachments/assets/4a9ec055-7c51-4861-8137-44896eb2c824)

![image](https://github.com/user-attachments/assets/50b9298f-b0c8-447b-ad7a-5c02f0f16cde)
![image](https://github.com/user-attachments/assets/750bd09b-1145-4ed8-8ce6-fe8946155e57)
![image](https://github.com/user-attachments/assets/dad50913-0e91-4246-99c3-9ca42acc6f25)
이런에러가 뜨면 , 
![image](https://github.com/user-attachments/assets/009ff084-4584-412d-9a29-9a05b82f6414)
기존 규칙을 삭제하고 다시 인바운드 규칙을 설정한다 
![image](https://github.com/user-attachments/assets/3dd7892c-7ea4-46f7-ac09-700fed75c48f)


![image](https://github.com/user-attachments/assets/1e583536-cbcf-4346-bcfb-e8701fa6f857)
