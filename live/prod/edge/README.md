# Prod Edge Stack

이 디렉터리는 프로덕션 환경 edge 인프라 root module입니다.

구성:

- `landing`: S3 + CloudFront + ACM + Cloudflare DNS
- `web`: S3 + CloudFront + ACM + Cloudflare DNS

도메인 정책:

- `fabbitinc.com`, `www.fabbitinc.com` -> landing
- `fabbit.app`, `*.fabbit.app` -> web
