# Cloudflare Infrastructure

Cloudflare Pages와 R2를 관리하는 OpenTofu 구성입니다.

## 구조

```
cloudflare/
├── modules/                 # 재사용 가능한 모듈 (템플릿)
│   ├── pages/              # Cloudflare Pages 모듈
│   └── r2/                 # Cloudflare R2 모듈
└── environments/           # 환경별 구성
    ├── dev/                # 개발 환경 (R2 + Pages)
    ├── prod/               # 프로덕션 환경 (R2 + Pages)
    └── landing/            # 랜딩 페이지 (Pages만)
```

## 환경별 리소스

| 환경 | 리소스 | 이름 | 용도 |
|------|--------|------|------|
| dev | R2 | `fabbit-dev` | 파일 저장소 |
| dev | Pages | `fabbit-web-dev` | 앱 프론트엔드 |
| prod | R2 | `fabbit-prod` | 파일 저장소 |
| prod | Pages | `fabbit-web-prod` | 앱 프론트엔드 |
| landing | Pages | `fabbit-landing` | 랜딩 페이지 |

## 사전 준비

### 1. 필요한 토큰

| 토큰 | 용도 | 발급 위치 |
|------|------|----------|
| API Token | Pages, R2 생성 | My Profile → API Tokens |
| Account ID | 계정 식별 | Dashboard 우측 또는 URL |
| R2 Access Key | S3 호환 API | R2 → Manage R2 API Tokens |
| R2 Secret Key | S3 호환 API | R2 토큰 생성 시 |

### 2. API Token 권한

- Account / Cloudflare Pages / Edit
- Account / Workers R2 Storage / Edit

## 사용법

### 환경변수 설정

```bash
export TF_VAR_cloudflare_api_token="your-api-token"
export TF_VAR_cloudflare_account_id="your-account-id"
export TF_VAR_r2_access_key_id="your-r2-access-key"
export TF_VAR_r2_secret_access_key="your-r2-secret-key"
```

### Dev 환경 배포

```bash
cd environments/dev
tofu init
tofu plan
tofu apply
```

### Prod 환경 배포

```bash
cd environments/prod
tofu init
tofu plan
tofu apply
```

### Landing 환경 배포

Landing은 Pages만 사용하므로 R2 토큰 없이 배포 가능합니다.

```bash
cd environments/landing
export TF_VAR_cloudflare_api_token="your-api-token"
export TF_VAR_cloudflare_account_id="your-account-id"
tofu init
tofu plan
tofu apply
```

## 모듈 사용 방식

```hcl
# modules/r2/ 는 템플릿
# environments/dev/main.tf 에서 호출하며 값 주입

module "r2_storage" {
  source      = "../../modules/r2"
  account_id  = var.cloudflare_account_id
  bucket_name = "fabbit-dev"        # 환경별로 다른 값
}
```

각 환경은 **독립적인 state**를 가지며, 서로 영향을 주지 않습니다.

## 배포 후 URL

| 프로젝트 | URL |
|---------|-----|
| 앱 (dev) | `fabbit-web-dev.pages.dev` |
| 앱 (prod) | `fabbit-web-prod.pages.dev` |
| 랜딩 | `fabbit-landing.pages.dev` |

## 커스텀 도메인 연결

Cloudflare Dashboard에서 Pages 프로젝트 → Custom domains에서 설정:

- `app.fabbitinc.com` → fabbit-web-prod
- `fabbitinc.com` → fabbit-landing
