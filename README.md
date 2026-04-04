# Fabbit Infrastructure

여러 벤더가 섞인 환경에서 OpenTofu root module을 벤더 기준이 아니라 스택 기준으로 관리합니다.

현재 원칙:
- `live/<env>/<stack>`: 실제 적용 단위
- `modules/<vendor>/<module>`: 재사용 모듈
- 루트 디렉터리 자체는 더 이상 단일 OpenTofu stack이 아닙니다
- 현재는 각 stack을 로컬 state로 관리합니다

## 현재 구조

```text
infra/
├── live/
│   └── prod/
│       ├── frontend/   # S3 + CloudFront + ACM + Cloudflare DNS
│       └── storage/    # Cloudflare R2
├── modules/
│   ├── aws/
│   │   ├── acm_certificate/
│   │   └── static_site/
│   └── cloudflare/
│       └── r2_bucket/
├── package.json        # 로컬 wrangler CLI
├── Makefile
└── CLAUDE.md
```

## 스택 경계

### frontend

- 역할: 정적 프런트 배포
- 리소스:
  - prod: S3, CloudFront, ACM, Cloudflare DNS
- 도메인 정책:
  - `fabbitinc.com`, `www.fabbitinc.com` -> landing
  - `www.fabbitinc.com` -> `fabbitinc.com` 301 redirect
  - `fabbit.app`, `*.fabbit.app` -> web
  - `api.fabbit.app` -> `193.122.102.209` (OCI Dokploy)

### storage

- 역할: Cloudflare R2
- 리소스: R2 bucket, CORS, custom domain
- `fabbit_app_zone_id`를 그대로 재사용합니다
- 위치: [live/prod/storage](/Users/moonseongha/code/projects/fabbit/infra/live/prod/storage)

## 실행

### Prod storage

```bash
cd live/prod/storage
tofu init
tofu plan
tofu apply
```

### Prod frontend

```bash
cd live/prod/frontend
tofu init
tofu plan
tofu apply
```

## 상태와 시크릿

### state

- 각 stack은 현재 로컬 state를 사용합니다
- `tofu init`만 실행하면 됩니다
- 원격 backend가 필요해지면 그때 별도 전환합니다

### secrets

권장 방식은 `secrets.tfvars`가 아니라 `TF_VAR_*` 환경변수 주입입니다.

`.env.example`를 복사해 `.env`를 만들고 값을 채운 뒤 `make`를 실행하면 됩니다.

예시:

```bash
cp .env.example .env
```

## 로컬 도구

`wrangler`는 글로벌 대신 repo 로컬 설치를 사용합니다.

```bash
pnpm install
pnpm wrangler whoami
```

## Makefile

반복 명령은 `Makefile`로 실행합니다.

```bash
make init-prod-frontend
make plan-prod-frontend
make apply-prod-frontend

make init-prod-storage
make plan-prod-storage
make apply-prod-storage

make validate
make fmt
```

`Makefile`은 루트 `.env`를 자동으로 읽습니다.
