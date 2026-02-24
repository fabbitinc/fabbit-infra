# Cloudflare Infrastructure

Cloudflare R2, Bulk Redirect를 관리하는 OpenTofu 구성입니다.
Pages 프로젝트는 Dashboard에서 직접 관리합니다 (Git 연동 포함).

## 구조

```
cloudflare/
├── modules/              # 재사용 가능한 모듈
│   └── r2/               # Cloudflare R2 (CORS는 AWS Provider S3 API)
├── web/                  # dev/prod 공유 코드 (R2 + Worker)
│   ├── main.tf
│   ├── worker.js         # Worker 스크립트 (서브도메인 라우터)
│   ├── variables.tf
│   ├── outputs.tf
│   └── envs/             # 환경별 tfvars, secrets, state
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

## 환경별 리소스

| 환경   | 리소스        | 이름                     | 용도                          |
| ------ | ------------- | ------------------------ | ----------------------------- |
| dev    | R2            | `fabbit-dev`             | 파일 저장소                   |
| prod   | R2            | `fabbit-prod`            | 파일 저장소                   |
| prod   | Worker        | `fabbit-worker-prod`     | 멀티테넌트 서브도메인 라우터  |
| (계정) | Bulk Redirect | `fabbit_pages_redirects` | pages.dev → 커스텀 도메인 301 |

## Pages 프로젝트 (Dashboard 관리)

Cloudflare provider v5 버그로 `cloudflare_pages_project`의 Git 연동/state 관리가 불안정하여,
Pages 프로젝트는 Dashboard에서 직접 생성합니다.

| Pages 프로젝트    | GitHub repo      | Production branch |
| ----------------- | ---------------- | ----------------- |
| `fabbit-landing`  | `fabbit/landing` | `main`            |
| `fabbit-web-dev`  | `fabbit/web`     | `dev`             |
| `fabbit-web-prod` | `fabbit/web`     | `main`            |

### 프로젝트 생성

[Cloudflare Dashboard](https://dash.cloudflare.com/) → Workers & Pages → Create → Pages → Connect to Git

### 빌드 설정

프로젝트 → Settings → Build configuration에서 설정:
- Build command, Output directory, Root directory, Node 버전 등

### 커스텀 도메인

프로젝트 → Custom domains에서 설정:
- `fabbit-landing` → `www.fabbitinc.com`
- `fabbit-web-prod` → `app.fabbitinc.com`

### 환경 변수

프로젝트 → Settings → Environment variables에서 설정:
- Production / Preview 환경별로 분리 가능

## Worker (멀티테넌트 서브도메인 라우터)

Cloudflare Pages는 와일드카드 커스텀 도메인을 지원하지 않으므로 (Enterprise 전용),
Worker가 `*.fabbitinc.com` 요청을 받아 Pages SPA를 프록시 서빙합니다.

### 동작 방식

1. `{org-slug}.fabbitinc.com` 요청 → Worker가 `fabbit-web.pages.dev`에서 SPA fetch
2. 예약 서브도메인(`www`, `app`, `api`, `api-dev`, `cdn`) → passthrough (기존 서비스 유지)
3. 404 + 확장자 없는 경로 → `/index.html` 반환 (SPA 클라이언트 라우팅)

### DNS 충돌 방지

- 구체적 DNS 레코드(`api`, `www`, `cdn`)가 와일드카드(`*`)보다 항상 우선
- Worker 내부에서도 `RESERVED_SUBDOMAINS` Set으로 이중 보호

Worker는 `cloudflare/web/` 배포에 포함됩니다 (`make web-plan ENV=prod`).

## 사전 준비

### 필요한 토큰

| 토큰          | 용도        | 발급 위치                 |
| ------------- | ----------- | ------------------------- |
| API Token     | R2 생성     | My Profile → API Tokens   |
| Account ID    | 계정 식별   | Dashboard 우측 또는 URL   |
| R2 Access Key | S3 호환 API | R2 → Manage R2 API Tokens |
| R2 Secret Key | S3 호환 API | R2 토큰 생성 시           |

### API Token 권한

- Account / Workers R2 Storage / Edit
- Account / Workers Scripts / Edit (Worker 배포용)
- Account / Account Rulesets / Edit (Bulk Redirect용)
- Zone / Workers Routes / Edit (Worker 라우트용)
- Zone / DNS / Edit (와일드카드 DNS용)

### secrets.tfvars 설정

```bash
# cloudflare/web/envs/dev.secrets.tfvars.example 참고
# cloudflare/redirects/envs/secrets.tfvars.example 참고
```

## 초기 배포 순서

### 1. Pages 프로젝트 생성 (Dashboard에서 수동)

위 [Pages 프로젝트 (Dashboard 관리)](#pages-프로젝트-dashboard-관리) 섹션 참고.

### 2. Web (dev) - R2 생성

```bash
cd cloudflare/web
tofu init
tofu plan  -var-file=envs/dev.tfvars -var-file=envs/dev.secrets.tfvars -state=envs/dev.tfstate
tofu apply -var-file=envs/dev.tfvars -var-file=envs/dev.secrets.tfvars -state=envs/dev.tfstate
```

### 3. Web (prod) - R2 생성

```bash
cd cloudflare/web
tofu plan  -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate
tofu apply -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate
```

### 4. Redirects - Bulk Redirect 생성

```bash
cd cloudflare/redirects
tofu init
tofu plan  -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/redirects.tfstate
tofu apply -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/redirects.tfstate
```

- `fabbit-landing.pages.dev` → `https://www.fabbitinc.com` (301)
- `fabbit-web-prod.pages.dev` → `https://www.fabbitinc.com` (301)

### 5. R2 출력값 확인 (AWS 배포에 필요)

```bash
cd cloudflare/web
tofu output -state=envs/prod.tfstate
```

## 이후 변경 적용

```bash
# Web (dev)
cd cloudflare/web
tofu plan  -var-file=envs/dev.tfvars -var-file=envs/dev.secrets.tfvars -state=envs/dev.tfstate
tofu apply -var-file=envs/dev.tfvars -var-file=envs/dev.secrets.tfvars -state=envs/dev.tfstate

# Web (prod)
cd cloudflare/web
tofu plan  -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate
tofu apply -var-file=envs/prod.tfvars -var-file=envs/prod.secrets.tfvars -state=envs/prod.tfstate

# Redirects
cd cloudflare/redirects
tofu plan  -var-file=envs/prod.tfvars -var-file=envs/secrets.tfvars -state=envs/redirects.tfstate
tofu apply -var-file=envs/prod.tfvars -var-file=envs/secrets.tfvars -state=envs/redirects.tfstate
```

## 인프라 삭제

```bash
# Web
cd cloudflare/web
tofu destroy -var-file=envs/{env}.tfvars -var-file=envs/{env}.secrets.tfvars -state=envs/{env}.tfstate

# Redirects
cd cloudflare/redirects
tofu destroy -var-file=envs/prod.tfvars -var-file=envs/secrets.tfvars -state=envs/redirects.tfstate
```

## 배포 후 URL

| 프로젝트  | pages.dev                   | 커스텀 도메인       |
| --------- | --------------------------- | ------------------- |
| 랜딩      | `fabbit-landing.pages.dev`  | `www.fabbitinc.com` |
| 앱 (dev)  | `fabbit-web-dev.pages.dev`  | -                   |
| 앱 (prod) | `fabbit-web-prod.pages.dev` | `app.fabbitinc.com` |

커스텀 도메인은 Cloudflare Dashboard → Pages → Custom domains에서 설정합니다.
