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
│       ├── edge/       # S3 + CloudFront + ACM + Cloudflare DNS + GitHub OIDC deploy role
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

### edge

- 역할: 웹 자산 전달, TLS, CDN, DNS 라우팅
- 리소스:
  - prod: S3, CloudFront, ACM, Cloudflare DNS, GitHub Actions OIDC IAM role
- 도메인 정책:
  - `fabbitinc.com`, `www.fabbitinc.com` -> landing
  - `fabbit.app`, `*.fabbit.app` -> web
  - `api.fabbit.app` -> `193.122.102.209` (OCI Dokploy)
- 캐시 정책:
  - CloudFront는 최신 `cache_policy_id` 기반 설정을 사용합니다
  - `index.html`은 no-cache, 나머지 정적 자산은 장기 캐시를 전제로 배포합니다

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

### Prod edge

```bash
cd live/prod/edge
tofu init
tofu plan
tofu apply
```

apply 후 `github_actions_role_arn` output을 GitHub repo secret `AWS_ROLE_TO_ASSUME`에 넣습니다.

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
make init-prod-edge
make plan-prod-edge
make apply-prod-edge

make init-prod-storage
make plan-prod-storage
make apply-prod-storage

make validate
make fmt
```

`Makefile`은 루트 `.env`를 자동으로 읽습니다.
