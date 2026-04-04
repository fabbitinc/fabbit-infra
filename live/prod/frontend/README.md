# Prod Frontend Stack

이 디렉터리는 프로덕션 환경 프런트 인프라 root module입니다.

구성:
- `landing`: S3 + CloudFront + ACM + Cloudflare DNS
- `web`: S3 + CloudFront + ACM + Cloudflare DNS

도메인 정책:
- `fabbitinc.com`, `www.fabbitinc.com` -> landing
- `www.fabbitinc.com`은 `fabbitinc.com`으로 301 redirect
- `fabbit.app`, `*.fabbit.app` -> web
- `api.fabbit.app` -> `193.122.102.209` (OCI Dokploy)
