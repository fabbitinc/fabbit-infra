# AWS Infrastructure

AWS EC2 + Cloudflare DNS를 관리하는 OpenTofu 구성입니다.
앱 환경 변수는 GitHub Actions에서 관리합니다 (Terraform 범위 외).

## 구조

```
aws/
├── modules/
│   └── ec2/              # EC2 + SG + EIP + Key Pair
├── main.tf               # Provider, module 호출, Cloudflare DNS
├── variables.tf
├── outputs.tf
└── envs/
    ├── dev.tfvars
    ├── dev.secrets.tfvars
    ├── prod.tfvars
    └── prod.secrets.tfvars
```

## 환경별 리소스

| 환경 | 리소스         | 용도                                  |
| ---- | -------------- | ------------------------------------- |
| dev  | EC2 (t3.small) | Docker Compose (FastAPI + PostgreSQL) |
| dev  | DNS A 레코드   | `api-dev.fabbitinc.com` → EC2 EIP     |
| prod | EC2 (t3.medium)| Docker Compose (FastAPI + PostgreSQL) |
| prod | DNS A 레코드   | `api.fabbitinc.com` → EC2 EIP         |

## EC2 인스턴스 구성

- **AMI**: Amazon Linux 2023
- **user_data**: Docker + Docker Compose 자동 설치
- **EBS**: 30GB gp3
- **Security Group**: SSH(22), HTTP(80), HTTPS(443) 인바운드
- **Elastic IP**: 고정 퍼블릭 IP (Cloudflare DNS에 연결)

## 사전 준비

### 필요한 토큰

| 토큰               | 용도             | 발급 위치                            |
| ------------------ | ---------------- | ------------------------------------ |
| AWS Credentials    | EC2 등 리소스    | IAM → Users → Security credentials  |
| Cloudflare API Token | DNS 레코드 생성 | My Profile → API Tokens             |
| Cloudflare Account ID | 계정 식별     | Dashboard 우측 또는 URL              |

### Cloudflare API Token 권한

- Zone / DNS / Edit (`fabbitinc.com` zone)

### AWS 인증

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
# 또는 ~/.aws/credentials 설정
```

### secrets.tfvars 설정

```bash
# aws/envs/dev.secrets.tfvars.example 참고
cp envs/dev.secrets.tfvars.example envs/dev.secrets.tfvars
# 값 채워넣기
```

## 초기 배포

```bash
cd aws
make init
make plan ENV=dev
make apply ENV=dev
```

## 이후 변경 적용

```bash
make plan ENV=dev
make apply ENV=dev

make plan ENV=prod
make apply ENV=prod
```

## 출력값 확인

```bash
make output ENV=dev
# ec2_public_ip   = "x.x.x.x"
# ec2_instance_id = "i-xxxxx"
# api_domain      = "api-dev.fabbitinc.com"
```

## 인프라 삭제

```bash
make destroy ENV=dev
```

## 배포 후 URL

| 환경 | API 도메인                |
| ---- | ------------------------- |
| dev  | `api-dev.fabbitinc.com`   |
| prod | `api.fabbitinc.com`       |

Cloudflare Proxy(proxied=true)가 HTTPS를 자동 처리합니다.
