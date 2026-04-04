# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

Fabbit 서비스의 인프라 코드로, OpenTofu(Terraform 호환)를 사용한 AWS + Cloudflare 하이브리드 인프라를 관리합니다.

## 주요 명령어

```bash
# 단일 루트 구조 — cd 없이 infra/ 루트에서 실행
tofu init
tofu plan  -var-file=envs/dev.tfvars  -var-file=envs/dev.secrets.tfvars  -state=envs/dev.tfstate
tofu apply -var-file=envs/dev.tfvars  -var-file=envs/dev.secrets.tfvars  -state=envs/dev.tfstate
tofu plan  -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate
tofu apply -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate

# 인프라 삭제
tofu destroy -var-file=envs/{env}.tfvars -var-file=envs/{env}.secrets.tfvars -state=envs/{env}.tfstate
```

## 아키텍처

```
Cloudflare (프론트엔드, 스토리지)
├── Pages (Dashboard에서 관리, Git 연동)
├── R2 (drawings/, documents/ 파일 저장소)
├── Worker (멀티테넌트 서브도메인 라우터)
└── DNS + Proxy → api(-dev).fabbit.app → EC2 Elastic IP (HTTPS 자동)
         │
         │ S3 API
         ▼
AWS (백엔드)
└── EC2 Instance (Elastic IP)
    ├── Docker Compose
    │   ├── FastAPI (port 8000)
    │   └── PostgreSQL (port 5432, volume 마운트)
    ├── IAM Instance Profile (SES 발송 권한)
    └── Security Group (80, 22)

SES → 트랜잭션 이메일 발송 (prod만)
GHCR → Docker 이미지 저장 (AWS 외부)
```

## 폴더 구조

```
infra/
├── modules/
│   ├── ec2/              # EC2 + SG + EIP + Key Pair
│   └── r2/               # R2 + CORS + Custom Domain
├── providers.tf          # terraform{}, provider 블록, locals
├── compute.tf            # IAM Role/Profile, EC2 모듈, API DNS, SSL
├── storage.tf            # R2 모듈, Worker, Worker 라우트, 와일드카드 DNS
├── email.tf              # SES + DKIM/SPF/DMARC DNS + SES IAM 정책
├── ci.tf                 # GitHub Actions OIDC + 배포 정책
├── monitoring.tf         # 비용 알림
├── redirects.tf          # Bulk Redirect (prod만)
├── variables.tf          # 모든 변수
├── outputs.tf            # 모든 출력
├── worker.js             # Worker 스크립트
└── envs/
    ├── dev.tfvars
    ├── dev.secrets.tfvars
    ├── dev.secrets.tfvars.example
    ├── prod.tfvars
    ├── prod.secrets.tfvars
    └── prod.secrets.tfvars.example
```

## 환경 변수 설정

```bash
# envs/ 하위 secrets.tfvars 파일로 관리
# envs/dev.secrets.tfvars.example 참고
# envs/prod.secrets.tfvars.example 참고
```

## 주요 설계 결정

### 관심사별 .tf 파일 분리
- 벤더별(aws/cloudflare)이 아닌 역할별(compute/storage/email/ci)로 파일 분리
- AWS + Cloudflare provider를 단일 state에서 함께 사용
- 환경 분리는 tfvars + state 파일로 처리

### Cloudflare Pages — Dashboard 관리
- Cloudflare provider v5 버그로 `cloudflare_pages_project` state 관리 불안정
- Dashboard에서 직접 생성 (GitHub 연동 포함)
- tofu에서는 Pages 리소스를 관리하지 않음

### R2 CORS 설정
- Cloudflare Provider는 CORS 미지원
- AWS Provider(`aws.r2` alias)로 S3 호환 API 사용하여 CORS 설정

### SES 이메일 (prod만)
- `ses_enabled = true`일 때만 SES + DNS 레코드 생성
- EC2 IAM Instance Profile을 통해 앱에서 Access Key 없이 SES API 호출
- SES Sandbox → Production 전환은 AWS 콘솔에서 별도 요청 필요

### Pages.dev → 커스텀 도메인 Bulk Redirect
- `*.pages.dev` 서브도메인 비활성화 불가 → bulk redirect로 커스텀 도메인 리다이렉트
- prod 환경에서만 생성 (`count = var.environment == "prod"`)

### 환경별 차이
| 구성 | Dev | Prod |
|------|-----|------|
| EC2 인스턴스 타입 | t3.small | t3.small |
| API 도메인 | api-dev.fabbit.app | api.fabbit.app |
| SSH 허용 IP | 넓게 | 특정 IP만 |
| SES | 비활성화 | 활성화 |
| R2 커스텀 도메인 | 없음 | cdn.fabbit.app |
| Bulk Redirect | 없음 | 활성화 |
