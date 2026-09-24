# Express·Redis CI/CD 파이프라인 실습

작은 메시지 API를 대상으로 **코드 변경 → 테스트·빌드 → 컨테이너 이미지 → AWS 배포 준비**의 흐름을 구성한 실습 프로젝트입니다. API는 TypeScript·Express로 만들고, 메시지는 Redis에 저장합니다. 기능 자체보다 애플리케이션과 Redis를 함께 검증하고 Docker 이미지를 ECR/ECS에 연결해 보는 과정에 초점을 맞췄습니다.

> **현재 범위:** PR 테스트와 `main` 푸시 시 Docker Compose 테스트가 워크플로에 정의되어 있습니다. ECR 이미지 업로드와 ECS 설정도 실습했지만, **테스트 통과부터 ECS 서비스 반영까지 자동으로 이어지는 배포는 완성되지 않았습니다.** 코드상 한계는 아래에 정리했습니다.

## 30초 요약

| 질문 | 답 |
| --- | --- |
| 무엇을 만드나? | `POST /messages`로 Redis에 메시지를 넣고 `GET /messages`로 조회하는 API |
| 무엇을 검증하나? | Redis를 사용하는 API 테스트(Jest·Supertest)와 TypeScript 빌드 |
| 자동화는 어디까지인가? | PR용 테스트 워크플로와 `main` 푸시용 Docker Compose 테스트 워크플로 구성 |
| AWS에서는 무엇을 했나? | ECR 이미지 업로드 스크립트와 ECS 클러스터·태스크 정의 연결 실습 |
| 아직 남은 것은? | 테스트 성공을 배포의 선행 조건으로 묶고, 스크립트를 Ubuntu 환경에 맞게 고친 뒤 ECS 갱신 자동화 |

## 프로젝트 흐름

```text
코드 변경
 ├─ Pull Request → npm ci → Redis 실행 → Jest 테스트 → TypeScript 빌드
 └─ main 푸시  → Docker Compose로 앱·Redis 테스트 실행
                  ↘ 별도 deploy 작업: AWS OIDC 인증 → 상태 확인 스크립트 → ECR 업로드 시도

ECR 이미지 → ECS 태스크 정의·클러스터 연결은 AWS 콘솔에서 실습
```

`main` 푸시 워크플로의 `test`와 `deploy`는 현재 **서로 독립된 작업**입니다. 그림은 실습한 구성요소를 보여 주며, 테스트 결과가 배포를 제어한다는 뜻은 아닙니다. 실제 설정은 [PR 테스트](.github/workflows/test.yml), [`main` 푸시 워크플로](.github/workflows/TestAndDeploy.yml), [ECR 업로드 스크립트](aws_cli_registry.sh)에서 확인할 수 있습니다.

## 애플리케이션과 검증

| 경로 | 동작 |
| --- | --- |
| `POST /messages` | 요청 본문의 `message`를 Redis의 `messages` 리스트 앞에 추가 |
| `GET /messages` | Redis 리스트의 메시지를 최신 항목부터 반환 |
| `GET /` | 고정 문자열 반환 |
| `GET /fibonacci/:n` | 재귀 피보나치 계산을 실행하는 실습용 경로 |
| `GET /crash` | 프로세스를 종료시키는 장애 실험용 경로 |

[app/app.ts](app/app.ts)에 API가, [app/index.ts](app/index.ts)에 Redis 연결과 서버 시작 코드가 있습니다. [app/index.test.ts](app/index.test.ts)는 Redis에 실제로 연결해 메시지 등록·조회 응답을 검사합니다.

## 로컬에서 실행하기

Docker와 Docker Compose가 설치되어 있다면 저장소 루트에서 실행합니다. [`docker-compose.yml`](docker-compose.yml)이 앱과 Redis를 함께 띄우고 앱을 `http://localhost:4000`에 연결합니다.

```bash
docker compose up --build
```

```bash
curl -X POST http://localhost:4000/messages \
  -H 'Content-Type: application/json' \
  -d '{"message":"hello"}'
curl http://localhost:4000/messages
```

Redis를 포함한 테스트는 별도 Compose 파일로 실행합니다. `--exit-code-from web`은 테스트 컨테이너의 종료 코드를 명령의 결과로 전달합니다.

```bash
docker compose -f docker-compose.test.yml up --build --abort-on-container-exit --exit-code-from web
```

TypeScript 빌드만 확인하려면 `npm ci` 후 `npm run build`를 실행합니다. `npm run test:ci`는 Redis 연결이 필요하며 테스트 파일은 `TEST_REDIS_URL` 환경 변수를 사용합니다.

## 주요 파일

| 파일 | 역할 |
| --- | --- |
| [`.github/workflows/test.yml`](.github/workflows/test.yml) | PR에서 패키지 설치, Redis 실행, 테스트·빌드 |
| [`.github/workflows/TestAndDeploy.yml`](.github/workflows/TestAndDeploy.yml) | `main` 푸시에서 Compose 테스트와 별도 배포 작업 실행 |
| [`docker-compose.test.yml`](docker-compose.test.yml) | 테스트용 앱·Redis 구성과 `TEST_REDIS_URL` 전달 |
| [`Dockerfile`](Dockerfile) / [`Dockerfile.dev`](Dockerfile.dev) | 빌드·실행용 이미지와 개발·테스트용 이미지 |
| [`git_api_status.sh`](git_api_status.sh) / [`aws_cli_registry.sh`](aws_cli_registry.sh) | 워크플로 상태 조회와 ECR 이미지 업로드 시도 |
| [`load-test.yml`](load-test.yml) | `/messages` 대상 부하 테스트 설정 파일. 실행 결과는 저장소에 없음 |

## 현재 상태와 남은 과제

이 저장소는 **배포 과정을 학습하고 연결해 본 기록**입니다. 다음은 코드에 남아 있는 한계이며, 배포 성공이나 운영 중인 서비스를 뜻하지 않습니다.

1. PR 워크플로는 Redis를 비밀번호와 함께 `6380` 포트에 띄우지만 테스트에 필요한 `TEST_REDIS_URL`을 전달하지 않습니다.
2. `main` 푸시 워크플로의 `deploy` 작업에는 `needs: test`가 없어 테스트 실패가 배포 작업을 막지 않습니다.
3. 배포 스크립트는 **이 저장소가 아닌** `express_infelearn`의 워크플로 상태를 조회합니다. 이어서 호출하는 ECR 스크립트는 Windows의 `powershell.exe`로 Docker Desktop을 실행하므로 GitHub Actions의 Ubuntu 러너와 맞지 않습니다.
4. ECR 이미지와 ECS 태스크 정의·클러스터를 연결하는 과정은 콘솔 실습 기록입니다. 저장소에는 ECS 서비스를 갱신하는 자동 배포 단계가 없습니다.

면접에서는 **API·Redis 통합 테스트, Docker Compose 검증, AWS OIDC/ECR/ECS 연결을 시도하며 드러난 배포 조건과 미완성 지점을 설명하는 프로젝트**로 소개하는 것이 정확합니다.

<details>
<summary>기존 AWS 콘솔 실습 기록과 스크린샷 보기</summary>

아래는 당시 ECR, ECS, VPC와 네트워크 설정을 살펴보며 남긴 화면입니다. 현재 서비스 가동이나 자동 배포 성공의 증거로 사용하지 않습니다. 코드의 AWS 리전은 `ap-northeast-2`이며, 이전 메모에는 다른 리전도 적혀 있어 화면의 설정값은 재확인이 필요합니다.

### ECR 이미지와 ECS 구성

![ECR 이미지 실습 화면](https://github.com/user-attachments/assets/6ff55fc3-9d1e-4233-9de6-67c7e4e00c3e)
![ECS 구성 화면 1](https://github.com/user-attachments/assets/d9ac62ea-a53f-4972-ab28-161e07a7964b)
![ECS 구성 화면 2](https://github.com/user-attachments/assets/3705eaae-785b-422c-ba43-0b05e22057ce)
![ECS 구성 화면 3](https://github.com/user-attachments/assets/1012d3e1-bd5c-4e77-8e62-a92e745f09d7)
![ECS 구성 화면 4](https://github.com/user-attachments/assets/df7813b1-14af-4229-9e8b-8ecc94ffbca6)
![ECS 구성 화면 5](https://github.com/user-attachments/assets/4a9ec055-7c51-4861-8137-44896eb2c824)
![ECS 구성 화면 6](https://github.com/user-attachments/assets/50b9298f-b0c8-447b-ad7a-5c02f0f16cde)
![ECS 구성 화면 7](https://github.com/user-attachments/assets/750bd09b-1145-4ed8-8ce6-fe8946155e57)

### VPC와 네트워크 설정

![VPC 확인 화면](https://github.com/user-attachments/assets/4adac64b-af0e-4e6e-8e54-17cd048271b3)
![서브넷 확인 화면](https://github.com/user-attachments/assets/cc96d42e-c691-448e-9e39-de6df1eab9f2)
![라우팅 테이블 확인 화면](https://github.com/user-attachments/assets/226ae67b-58d7-49c9-bf6e-1bcc1e1b39be)
![인터넷 게이트웨이 확인 화면](https://github.com/user-attachments/assets/002b4936-1535-458d-a2cc-86cdb77c90d2)
![네트워크 설정 확인 화면](https://github.com/user-attachments/assets/dad50913-0e91-4246-99c3-9ca42acc6f25)
![오류 확인 화면](https://github.com/user-attachments/assets/009ff084-4584-412d-9a29-9a05b82f6414)
![인바운드 규칙 확인 화면](https://github.com/user-attachments/assets/3dd7892c-7ea4-46f7-ac09-700fed75c48f)
![추가 설정 확인 화면](https://github.com/user-attachments/assets/1e583536-cbcf-4346-bcfb-e8701fa6f857)

</details>

