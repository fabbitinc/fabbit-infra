# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

Fabbit 서비스의 인프라 코드로, OpenTofu(Terraform 호환)를 사용한 AWS + Cloudflare 하이브리드 인프라를 관리합니다.

## 주요 명령어

```bash
# AWS (dev/prod 공유 코드, tfvars로 환경 분리)
cd aws
tofu init
tofu plan  -var-file=envs/dev.tfvars -var-file=envs/dev.secrets.tfvars -state=envs/dev.tfstate
tofu apply -var-file=envs/dev.tfvars -var-file=envs/dev.secrets.tfvars -state=envs/dev.tfstate
tofu plan  -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate
tofu apply -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate

# Cloudflare Web (dev/prod 공유 코드, tfvars로 환경 분리)
cd cloudflare/web
tofu init
tofu plan  -var-file=envs/dev.tfvars -var-file=envs/dev.secrets.tfvars -state=envs/dev.tfstate
tofu apply -var-file=envs/dev.tfvars -var-file=envs/dev.secrets.tfvars -state=envs/dev.tfstate
tofu plan  -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate
tofu apply -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate

# Cloudflare Redirects (pages.dev → 커스텀 도메인, 계정 레벨)
cd cloudflare/redirects
tofu init
tofu plan  -var-file=envs/prod.tfvars -var-file=envs/secrets.tfvars -state=envs/redirects.tfstate
tofu apply -var-file=envs/prod.tfvars -var-file=envs/secrets.tfvars -state=envs/redirects.tfstate

# 인프라 삭제 (AWS 먼저, Cloudflare 나중에)
cd aws
tofu destroy -var-file=envs/{env}.tfvars -var-file=envs/{env}.secrets.tfvars -state=envs/{env}.tfstate

cd cloudflare/web
tofu destroy -var-file=envs/{env}.tfvars -var-file=envs/{env}.secrets.tfvars -state=envs/{env}.tfstate

cd cloudflare/redirects
tofu destroy -var-file=envs/prod.tfvars -var-file=envs/secrets.tfvars -state=envs/redirects.tfstate
```

## 아키텍처

```
Cloudflare (프론트엔드, 스토리지)
├── Pages (Dashboard에서 관리, Git 연동)
├── R2 (drawings/, documents/ 파일 저장소)
└── DNS + Proxy → api(-dev).fabbitinc.com → EC2 Elastic IP (HTTPS 자동)
         │
         │ S3 API
         ▼
AWS (백엔드)
└── EC2 Instance (Elastic IP)
    ├── Docker Compose
    │   ├── FastAPI (port 8000)
    │   └── PostgreSQL (port 5432, volume 마운트)
    ├── IAM Instance Profile (SSM 읽기 권한)
    └── Security Group (80, 443, 22)

SSM Parameter Store → 시크릿 저장
GHCR → Docker 이미지 저장 (AWS 외부)
```

## 폴더 구조

```
infra/
├── aws/
│   ├── modules/
│   │   └── ec2/              # EC2 + SG + EIP + Key Pair + IAM Role
│   ├── main.tf               # Provider, locals, module 호출, SSM, DNS
│   ├── variables.tf
│   ├── outputs.tf
│   └── envs/
│       ├── dev.tfvars
│       ├── dev.secrets.tfvars
│       ├── prod.tfvars
│       └── prod.secrets.tfvars
├── azure/                    # (레거시, 마이그레이션 후 삭제 예정)
└── cloudflare/
    ├── modules/              # 재사용 가능한 Cloudflare 모듈
    │   └── r2/               # CORS는 S3 호환 API(AWS Provider)로 설정
    ├── web/                  # dev/prod 공유 코드 (R2)
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── envs/
    │       ├── dev.tfvars
    │       ├── dev.secrets.tfvars
    │       ├── prod.tfvars
    │       └── prod.secrets.tfvars
    ├── redirects/            # pages.dev → 커스텀 도메인 Bulk Redirect (계정 레벨)
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── envs/
    │       ├── prod.tfvars
    │       └── secrets.tfvars
    └── landing/              # (리소스 없음, 레거시)
```

## 환경 변수 설정

```bash
# AWS - envs/ 하위 secrets.tfvars 파일로 관리
# aws/envs/dev.secrets.tfvars.example 참고

# Cloudflare - envs/ 하위 secrets.tfvars 파일로 관리
# cloudflare/web/envs/dev.secrets.tfvars.example 참고
# cloudflare/redirects/envs/secrets.tfvars.example 참고
```

## 배포 순서

1. **Cloudflare 먼저 배포** - R2 엔드포인트 정보 생성
2. `tofu output`으로 R2 정보 확인
3. **AWS 배포** - EC2 + SSM + DNS 생성

## 주요 설계 결정

### Cloudflare Pages - Dashboard 관리
- Cloudflare provider v5 버그로 `cloudflare_pages_project` state 관리 불안정
- Dashboard에서 직접 생성 (GitHub 연동 포함)
- tofu에서는 Pages 리소스를 관리하지 않음

### R2 CORS 설정
- Cloudflare Provider는 CORS 미지원
- AWS Provider로 S3 호환 API 사용하여 CORS 설정

### Pages.dev → 커스텀 도메인 Bulk Redirect
- `*.pages.dev` 서브도메인 비활성화 불가 → bulk redirect로 커스텀 도메인 리다이렉트
- `fabbit-landing.pages.dev` → `https://www.fabbitinc.com` (301)
- `fabbit-web-prod.pages.dev` → `https://www.fabbitinc.com` (301)
- 계정 레벨 리소스이므로 `cloudflare/redirects/`에서 독립 관리

### 환경별 차이
| 구성 | Dev | Prod |
|------|-----|------|
| EC2 인스턴스 타입 | t3.small | t3.medium |
| API 도메인 | api-dev.fabbitinc.com | api.fabbitinc.com |
| SSH 허용 IP | 넓게 | 특정 IP만 |
