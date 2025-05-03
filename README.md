먼저 부분적으로 
aws_cli_registry.sh을 실행하면, aws ECR로 image가 로드된다 
![image](https://github.com/user-attachments/assets/6ff55fc3-9d1e-4233-9de6-67c7e4e00c3e)
그 다음에 aws ecs로 가서 , 클러스터를 만들고 aws ecs에서 테스크 정의를 해준다 , 거기에서 로드된 ECR의 image를 사용한다 
그리고 클러스터에서 ![image](https://github.com/user-attachments/assets/d9ac62ea-a53f-4972-ab28-161e07a7964b)
이걸로 생성하는건데 , 지금 load balancersl , 네트워크니 잘 설정이 안되 있어서 잘 안되네 
![image](https://github.com/user-attachments/assets/3705eaae-785b-422c-ba43-0b05e22057ce)


![Uploading image.png…]()
