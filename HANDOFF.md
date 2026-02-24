# Handoff: Cloudflare Worker 멀티테넌트 서브도메인 라우터

## Goal

멀티테넌트 구조에서 `{org-slug}.fabbitinc.com` 와일드카드 서브도메인을 Cloudflare Worker로 라우팅.
Cloudflare Pages는 와일드카드 커스텀 도메인 미지원(Enterprise 전용)이므로, Worker가 `*.fabbitinc.com` 요청을 받아 `fabbit-web.pages.dev` Pages SPA를 프록시 서빙한다.

## Current Progress

### 완료

- **Worker 코드 + Terraform 리소스 구현** — `cloudflare/web/`에 통합 (별도 `worker/` 폴더 X)
  - `cloudflare/web/worker.js` — Worker 스크립트 (templatefile 템플릿)
  - `cloudflare/web/main.tf` — 3개 리소스 추가: `cloudflare_workers_script`, `cloudflare_workers_route`, `cloudflare_dns_record`
  - `cloudflare/web/variables.tf` — `domain`, `pages_origin` 변수 추가
  - `cloudflare/web/outputs.tf` — `worker_script_name`, `worker_route_pattern` 출력 추가
  - `cloudflare/web/envs/prod.tfvars` — `domain = "fabbitinc.com"`, `pages_origin = "https://fabbit-web.pages.dev"` 추가
  - `cloudflare/web/envs/dev.tfvars` — `domain`, `pages_origin` 추가
- **prod 배포 완료** — Worker 정상 동작 확인 (`X-Served-By: fabbit-worker` 헤더)
- **Bulk Redirect 충돌 발견 및 수정** — `redirect_web_prod` 규칙 제거 (`cloudflare/redirects/main.tf`)
- **README.md, Makefile 업데이트** 완료
- `tofu validate` 통과

### 배포 상태

| 환경 | 상태 |
|------|------|
| `cloudflare/web` (prod) | 배포 완료 |
| `cloudflare/redirects` | **미배포** — `redirect_web_prod` 삭제 반영 필요 |

## What Worked

- Worker를 `cloudflare/web/`에 통합 — 기존 배포 단위(web = R2 + Worker) 유지
- Cloudflare provider v5 스키마 확인: `cloudflare_workers_route`는 `script` (not `script_name`), `cloudflare_dns_record`는 `ttl` 필수
- `templatefile()`로 `pages_origin`을 worker.js에 주입
- 예약 서브도메인(`www`, `app`, `api`, `api-dev`, `cdn`) Set으로 passthrough 처리

## What Didn't Work

- **처음에 `cloudflare/worker/` 별도 폴더로 생성** → 기존 컨벤션(배포 단위별 폴더)에 맞지 않아 `cloudflare/web/`에 통합
- **Cloudflare provider v5 속성명 추측 실패**:
  - `cloudflare_workers_route.script_name` → 실제는 `script`
  - `cloudflare_dns_record`에 `ttl` 누락 → v5에서 필수 (proxied일 때 `ttl = 1`)
  - `tofu validate`로 잡아서 수정
- **Bulk Redirect 간섭 미예상**: Worker의 `fetch("https://fabbit-web.pages.dev")`가 Bulk Redirect(`fabbit-web.pages.dev → www.fabbitinc.com`)에 걸려 랜딩 페이지를 반환. Worker subrequest도 account-level Bulk Redirect를 탐. `redirect_web_prod` 규칙 제거로 해결.

## Next Steps

1. **`cloudflare/redirects` 재배포** — `redirect_web_prod` 삭제 반영
   ```bash
   cd cloudflare/redirects
   make redirects-plan    # 1개 리소스 삭제 확인
   make redirects-apply
   ```

2. **검증**
   ```bash
   curl -sI https://test-org.fabbitinc.com  # X-Served-By: fabbit-worker + web app 내용
   curl -sI https://www.fabbitinc.com       # 랜딩 페이지 (변함없이)
   curl -sI https://api.fabbitinc.com       # API passthrough (변함없이)
   ```

3. **CLAUDE.md 업데이트** — `cloudflare/worker/` 관련 내용을 `cloudflare/web/`로 반영 (구조, 명령어)

4. **추후 작업** — CDN cookie 로직 추가 시 `cloudflare/web/worker.js`에 직접 추가

## Key Files

| 파일 | 역할 |
|------|------|
| `cloudflare/web/worker.js` | Worker 스크립트 (templatefile 템플릿) |
| `cloudflare/web/main.tf` | R2 + Worker 리소스 |
| `cloudflare/web/variables.tf` | `domain`, `pages_origin` 포함 |
| `cloudflare/redirects/main.tf` | `redirect_web_prod` 삭제됨 |
