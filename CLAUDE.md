# CLAUDE.md

## 개요

이 repo는 벤더 기준 폴더가 아니라 `live/<env>/<stack>` 기준으로 OpenTofu를 관리합니다.

핵심 원칙:
- 루트 디렉터리 자체는 단일 Terraform stack이 아닙니다
- 실제 적용은 각 `live/...` 디렉터리에서 실행합니다
- 재사용 코드는 `modules/`에 둡니다
- 각 stack은 현재 로컬 state를 사용합니다
- 시크릿은 루트 `.env`에 `TF_VAR_*` 형식으로 두는 것을 기본값으로 봅니다

## 현재 스택

- `live/prod/storage`: Cloudflare R2 prod
- `live/prod/edge`: AWS edge prod

## 현재 모듈

- `modules/cloudflare/r2_bucket`
- `modules/aws/acm_certificate`
- `modules/aws/static_site`

## 주요 명령

```bash
# Prod storage
cd live/prod/storage
tofu init
tofu plan
tofu apply

# Prod edge
cd live/prod/edge
tofu init
tofu plan
tofu apply
```

## 주의

- 예전 flat root Terraform 파일은 제거했습니다
- 예전 EC2 / Worker / Pages / Redirect / SES 코드는 현재 구조에 포함되지 않습니다
- `live/prod/edge`는 S3 + CloudFront + ACM + Cloudflare DNS를 같이 관리합니다
- `live/prod/edge`는 GitHub Actions OIDC 배포용 IAM role도 같이 관리합니다
- CloudFront는 legacy `forwarded_values` 대신 최신 cache policy를 사용합니다
- `fabbit.app`와 `*.fabbit.app`는 같은 web distribution으로 연결합니다
- `api.fabbit.app`는 wildcard 예외로 OCI Dokploy 서버 `193.122.102.209`를 가리킵니다
- `live/prod/storage`는 별도 `app_zone_id` 없이 `fabbit_app_zone_id`를 재사용합니다
- 반복 명령은 `Makefile`을 통해 실행합니다
- `Makefile`은 루트 `.env`를 자동으로 읽습니다
- remote backend와 lock table은 현재 사용하지 않습니다
