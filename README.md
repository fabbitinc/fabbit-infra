# Fabbit Infrastructure

OpenTofu(Terraform 호환)를 사용한 Azure + Cloudflare 하이브리드 인프라 구성입니다.

## 아키텍처

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              Cloudflare                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    │
│  │  Cloudflare     │    │   R2 Bucket     │    │   R2 Bucket     │    │
│  │  Pages (Web)    │    │   (drawings)    │    │   (documents)   │    │
│  └────────┬────────┘    └────────┬────────┘    └────────┬────────┘    │
│           │                      │                      │              │
└───────────┼──────────────────────┼──────────────────────┼──────────────┘
            │                      │                      │
            │ HTTPS                │ S3 API              │ S3 API
            ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                               Azure                                      │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    │
│  │  Container App  │────│   PostgreSQL    │    │   Key Vault     │    │
│  │     (API)       │    │   Flexible      │    │   (Secrets)     │    │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘    │
│                                                                         │
│  ┌─────────────────┐                                                   │
│  │  Container      │                                                   │
│  │  Registry       │                                                   │
│  └─────────────────┘                                                   │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                            GitHub Actions                               │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Push/PR → Build (npm run build) → wrangler pages deploy        │  │
│  └─────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

## 사전 요구사항

- [OpenTofu](https://opentofu.org/) >= 1.6.0 (`brew install opentofu`)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) (`brew install azure-cli`)
- Azure 구독
- Cloudflare 계정 및 API 토큰

## 폴더 구조

```
infra/
├── README.md
├── .gitignore
├── .github/
│   └── workflows/
│       └── deploy-web.yml        # 예시 GitHub Actions workflow
├── azure/                        # Azure 인프라 (백엔드)
│   ├── modules/
│   │   ├── resource-group/       # 리소스 그룹
│   │   ├── postgresql/           # PostgreSQL Flexible Server
│   │   ├── container-registry/   # Container Registry
│   │   ├── container-apps/       # Container Apps
│   │   └── key-vault/            # Key Vault
│   └── environments/
│       ├── dev/                  # 개발 환경
│       └── prod/                 # 프로덕션 환경
└── cloudflare/                   # Cloudflare 인프라 (프론트엔드, 스토리지)
    ├── modules/
    │   ├── pages/                # Cloudflare Pages (Direct Upload)
    │   └── r2/                   # R2 객체 스토리지
    └── environments/
        ├── dev/                  # 개발 환경
        └── prod/                 # 프로덕션 환경
```

## 생성되는 리소스

### Azure (백엔드)

| 리소스 | 용도 |
|--------|------|
| Resource Group | 리소스 그룹 (환경별) |
| PostgreSQL Flexible Server | 데이터베이스 |
| Container Apps Environment | 컨테이너 앱 실행 환경 |
| Container App | FastAPI 백엔드 |
| Container Registry | Docker 이미지 저장소 |
| Key Vault | 시크릿 관리 |

### Cloudflare (프론트엔드, 스토리지)

| 리소스 | 용도 |
|--------|------|
| Pages | React 프론트엔드 (Direct Upload) |
| R2 Bucket (drawings) | 도면 파일 저장소 |
| R2 Bucket (documents) | 문서 파일 저장소 |

## 시작하기

### 1. 인증 설정

**Azure 로그인**
```bash
az login
az account set --subscription "<구독-ID>"
```

**Cloudflare API 토큰 발급**
1. Cloudflare Dashboard → My Profile → API Tokens
2. Create Token → Edit Cloudflare Workers 템플릿 사용 또는 커스텀 생성
3. 필요 권한: Account > Cloudflare Pages (Edit), Account > Workers R2 Storage (Edit)

### 2. 환경 변수 설정

민감한 변수는 환경 변수로 전달하세요:

**Cloudflare (Terraform)**
```bash
export TF_VAR_cloudflare_api_token="<Cloudflare-API-토큰>"
export TF_VAR_cloudflare_account_id="<Cloudflare-계정-ID>"
export TF_VAR_r2_access_key_id="<R2-Access-Key-ID>"
export TF_VAR_r2_secret_access_key="<R2-Secret-Access-Key>"
```

**Azure**
```bash
export TF_VAR_postgresql_password="<강력한-비밀번호>"
export TF_VAR_openai_api_key="<OpenAI-API-키>"
export TF_VAR_r2_access_key_id="<R2-Access-Key-ID>"
export TF_VAR_r2_secret_access_key="<R2-Secret-Access-Key>"
```

또는 `secrets.tfvars` 파일을 생성하세요 (`.gitignore`에 포함됨).

### 3. 배포 순서

> **중요**: Cloudflare를 먼저 배포해야 R2 엔드포인트 정보를 Azure에 전달할 수 있습니다.

**Step 1: Cloudflare 배포**
```bash
cd infra/cloudflare/environments/dev

# 초기화
tofu init

# 구성 검증
tofu validate

# 배포 계획 확인
tofu plan

# 배포 실행
tofu apply

# 출력값 확인 (Azure 배포에 필요)
tofu output
```

**Step 2: Azure 배포**
```bash
cd infra/azure/environments/dev

# Cloudflare 출력값을 terraform.tfvars 또는 환경 변수에 설정
export TF_VAR_r2_endpoint_url="<Cloudflare-출력의-r2_endpoint>"
export TF_VAR_r2_bucket_name="<Cloudflare-출력의-r2_drawings_bucket_name>"

# 초기화
tofu init

# 배포 실행
tofu apply
```

**Step 3: GitHub Actions 설정**

GitHub 저장소에 다음 Secrets 및 Variables를 설정하세요:

**Secrets:**
- `CLOUDFLARE_API_TOKEN`: Cloudflare API 토큰
- `CLOUDFLARE_ACCOUNT_ID`: Cloudflare 계정 ID

**Variables:**
- `DEV_API_URL`: 개발 환경 API URL (예: `https://ca-fabbit-api-dev.xxx.azurecontainerapps.io`)
- `PROD_API_URL`: 프로덕션 환경 API URL

### 4. 프로덕션 배포

```bash
# Cloudflare
cd infra/cloudflare/environments/prod
tofu init && tofu apply

# Azure
cd infra/azure/environments/prod
tofu init && tofu apply
```

## Cloudflare Pages 배포 방식

Cloudflare Pages는 **Direct Upload** 방식을 사용합니다:

1. Terraform은 빈 Pages 프로젝트만 생성 (Git 연동 없음)
2. GitHub Actions에서 빌드 수행 (`npm run build`)
3. Wrangler CLI로 빌드 결과물을 Pages에 업로드

**장점:**
- 빌드 환경 완전 제어 (Node 버전, 캐시 등)
- 빌드 전후 추가 작업 가능 (테스트, 린트 등)
- GitHub Actions 분당 무료 시간 활용

**배포 트리거:**
- `main` 브랜치 push → prod 환경 배포
- `develop` 브랜치 push → dev 환경 배포
- PR → dev 프로젝트에 preview 배포

예시 workflow는 `.github/workflows/deploy-web.yml`을 참조하세요.
실제 사용 시 `web` 저장소의 `.github/workflows/`에 배치하세요.

## 환경별 차이점

### Azure

| 구성 | Dev | Prod |
|------|-----|------|
| PostgreSQL SKU | B_Standard_B1ms | GP_Standard_D2s_v3 |
| PostgreSQL 스토리지 | 32GB | 64GB |
| 백업 보존 기간 | 7일 | 14일 |
| 지리적 중복 백업 | 비활성화 | 활성화 |
| Container Registry | Basic | Standard |
| Container App 레플리카 | 0-3 | 1-10 |
| Container App CPU/메모리 | 0.5 / 1Gi | 1.0 / 2Gi |
| 로그 보존 기간 | 30일 | 90일 |
| Key Vault 퍼지 보호 | 비활성화 | 활성화 |

### Cloudflare

| 구성 | Dev | Prod |
|------|-----|------|
| Pages 프로덕션 브랜치 | develop | main |
| Preview 배포 | GitHub Actions에서 처리 | 비활성화 |

## 출력값

### Cloudflare
```bash
cd infra/cloudflare/environments/dev
tofu output
```

- `r2_drawings_bucket_name`: 도면 저장용 R2 버킷 이름
- `r2_documents_bucket_name`: 문서 저장용 R2 버킷 이름
- `r2_endpoint`: R2 S3 호환 엔드포인트
- `pages_subdomain`: Pages 기본 서브도메인
- `pages_project_name`: Pages 프로젝트 이름

### Azure
```bash
cd infra/azure/environments/dev
tofu output
```

- `container_app_url`: API 엔드포인트 URL
- `postgresql_server_fqdn`: 데이터베이스 서버 FQDN
- `container_registry_login_server`: 컨테이너 레지스트리 주소
- `key_vault_uri`: Key Vault URI

## 인프라 삭제

```bash
# Azure 먼저 삭제
cd infra/azure/environments/dev
tofu destroy

# Cloudflare 삭제
cd infra/cloudflare/environments/dev
tofu destroy
```

## 트러블슈팅

### R2 API 토큰 발급

1. Cloudflare Dashboard → R2 → Manage R2 API Tokens
2. Create API Token → Object Read & Write 권한 선택
3. Access Key ID와 Secret Access Key 저장

### GitHub Actions 배포 실패

1. GitHub Secrets에 `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` 설정 확인
2. API 토큰에 Pages 배포 권한 있는지 확인
3. 프로젝트 이름이 Terraform 출력값과 일치하는지 확인

### 리소스 이름 충돌

Container Registry, Key Vault 등은 전역적으로 고유한 이름이 필요합니다.
이름 충돌 시 프로젝트명을 수정하거나 랜덤 접미사를 추가하세요.

### CORS 설정

R2 버킷의 CORS는 AWS S3 호환 API를 통해 설정됩니다.
프론트엔드 도메인이 변경되면 `cors_allowed_origins` 변수를 업데이트하세요.
