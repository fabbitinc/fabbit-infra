# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

Fabbit 서비스의 인프라 코드로, OpenTofu(Terraform 호환)를 사용한 Azure + Cloudflare 하이브리드 인프라를 관리합니다.

## 주요 명령어

```bash
# 환경별 배포 (Cloudflare 먼저, Azure 나중에)
cd cloudflare/environments/{dev|prod|landing}
tofu init
tofu plan
tofu apply

cd azure/environments/{dev|prod}
tofu init
tofu plan
tofu apply

# 인프라 삭제 (Azure 먼저, Cloudflare 나중에)
cd azure/environments/{env}
tofu destroy

cd cloudflare/environments/{env}
tofu destroy
```

## 아키텍처

```
Cloudflare (프론트엔드, 스토리지)
├── Pages (React 앱, Direct Upload 방식)
└── R2 (drawings/, documents/ 파일 저장소)
         │
         │ S3 API
         ▼
Azure (백엔드)
├── Container App (FastAPI API)
├── PostgreSQL Flexible Server
├── Container Registry
└── Key Vault
```

## 폴더 구조

```
infra/
├── azure/
│   ├── modules/          # 재사용 가능한 Azure 모듈
│   │   ├── resource-group/
│   │   ├── postgresql/
│   │   ├── container-registry/
│   │   ├── container-apps/
│   │   └── key-vault/
│   └── environments/     # 환경별 구성
│       ├── dev/
│       └── prod/
└── cloudflare/
    ├── modules/          # 재사용 가능한 Cloudflare 모듈
    │   ├── pages/        # Direct Upload 방식
    │   └── r2/           # CORS는 S3 호환 API(AWS Provider)로 설정
    └── environments/
        ├── dev/
        ├── prod/
        └── landing/      # Pages만 사용
```

## 환경 변수 설정

```bash
# Cloudflare
export TF_VAR_cloudflare_api_token="..."
export TF_VAR_cloudflare_account_id="..."
export TF_VAR_r2_access_key_id="..."
export TF_VAR_r2_secret_access_key="..."

# Azure
export TF_VAR_postgresql_password="..."
export TF_VAR_openai_api_key="..."
export TF_VAR_r2_access_key_id="..."
export TF_VAR_r2_secret_access_key="..."
export TF_VAR_r2_endpoint_url="..."  # Cloudflare 출력값
export TF_VAR_r2_bucket_name="..."   # Cloudflare 출력값
```

## 배포 순서

1. **Cloudflare 먼저 배포** - R2 엔드포인트 정보 생성
2. `tofu output`으로 R2 정보 확인
3. **Azure 배포** - Cloudflare 출력값을 환경 변수로 전달

## 주요 설계 결정

### Cloudflare Pages - Direct Upload 방식
- Git 연동 없이 빈 프로젝트만 생성
- GitHub Actions에서 빌드 → Wrangler CLI로 배포
- 빌드 환경 완전 제어 (Node 버전, 캐시 등)

### R2 CORS 설정
- Cloudflare Provider는 CORS 미지원
- AWS Provider로 S3 호환 API 사용하여 CORS 설정

### 환경별 차이
| 구성 | Dev | Prod |
|------|-----|------|
| PostgreSQL SKU | B_Standard_B1ms | GP_Standard_D2s_v3 |
| Container App 레플리카 | 0-3 | 1-10 |
| Key Vault 퍼지 보호 | 비활성화 | 활성화 |
