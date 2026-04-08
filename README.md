# Fabbit Infrastructure

Fabbit SaaS 플랫폼의 인프라 코드입니다. **OpenTofu**로 AWS와 Cloudflare를 통합 관리합니다. 벤더 기준이 아닌 환경과 책임 단위로 스택을 구성합니다.

---

## 기술 스택

| 계층 | 기술 |
|---|---|
| IaC 도구 | OpenTofu (Terraform 호환, BSL-free) |
| CDN / TLS | AWS CloudFront + ACM |
| 정적 호스팅 | AWS S3 |
| 오브젝트 스토리지 | Cloudflare R2 |
| DNS | Cloudflare |
| CI/CD 인증 | GitHub Actions OIDC (장기 자격증명 없음) |
| 시크릿 관리 | `TF_VAR_*` 환경변수 (`.tfvars` 파일 미커밋) |

---

## 디렉토리 구조

```
infra/
├── live/
│   └── prod/
│       ├── edge/       S3 + CloudFront + ACM + Cloudflare DNS + GitHub OIDC
│       └── storage/    Cloudflare R2 버킷 + CORS
└── modules/
    ├── aws/
    │   ├── acm_certificate/    DNS 검증 TLS 인증서
    │   └── static_site/        S3 + CloudFront 배포 (재사용 모듈)
    └── cloudflare/
        └── r2_bucket/          R2 버킷 + CORS 정책 (재사용 모듈)
```

재사용 모듈은 `modules/`에 위치합니다. 각 `live/<env>/<stack>` 디렉토리는 독립적으로 적용 가능한 루트 모듈이며 자체 state를 가집니다.

---

## 라우팅 아키텍처

모든 트래픽은 CloudFront + Cloudflare DNS 계층에서 라우팅됩니다. API 서버는 이 레포 외부에서 관리되는 별도 OCI 인스턴스에서 실행됩니다.

```
fabbitinc.com         ──► S3 (랜딩 페이지)
www.fabbitinc.com     ──► S3 (랜딩 페이지)

fabbit.app            ──► S3 (웹 앱)
*.fabbit.app          ──► S3 (웹 앱)

api.fabbit.app        ──► OCI Dokploy 서버 (백엔드 API)
                           (CloudFront 와일드카드 예외 → 직접 오리진)
```

**캐시 전략:**
- `index.html` — `Cache-Control: no-cache` (진입점 항상 재요청)
- 정적 에셋 (`/assets/*`) — 장기 캐시 (콘텐츠 해시 파일명)

---

## GitHub Actions OIDC CI/CD

`edge` 스택은 GitHub Actions가 OIDC로 assume하는 IAM 역할을 프로비저닝합니다. AWS 액세스 키를 레포지토리 시크릿에 저장하지 않습니다.

```hcl
# GitHub Actions 워크플로우에서 사용:
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
    aws-region: us-east-1
```

역할 ARN은 `tofu apply` 출력값으로 받아 GitHub 레포지토리 시크릿에 한 번만 설정합니다. 이후 배포는 자격증명 없이 완전 자동화됩니다.

---

## 실행

**사전 요구사항:** OpenTofu, Cloudflare API 토큰, AWS 자격증명

```bash
# 시크릿 파일 복사 및 입력
cp .env.example .env

# edge 스택 배포 (CloudFront + S3 + DNS + OIDC 역할)
make init-prod-edge
make plan-prod-edge
make apply-prod-edge

# storage 스택 배포 (Cloudflare R2)
make init-prod-storage
make plan-prod-storage
make apply-prod-storage

# 전체 모듈 검증 및 포맷
make validate
make fmt
```

`make`는 루트 `.env` 파일을 자동으로 읽으므로 `TF_VAR_*` 변수를 수동으로 export할 필요가 없습니다.

---

## 설계 결정

**Terraform 대신 OpenTofu를 선택한 이유**  
HashiCorp가 2023년 Terraform 라이선스를 BSL로 변경했습니다. OpenTofu는 커뮤니티가 관리하는 MPL 라이선스 포크로 완전한 API 호환성을 제공합니다. 마이그레이션 비용 없이 향후 라이선스 리스크를 제거합니다.

**벤더 기준 대신 스택 기반 레이아웃을 선택한 이유**  
`edge` 스택은 AWS(CloudFront, ACM)와 Cloudflare(DNS 레코드) 리소스가 함께 존재해야 합니다. 벤더로 분리하면 논리적으로 하나인 작업을 위해 두 개의 별도 디렉토리 간 인위적인 의존성이 생깁니다. 스택은 벤더 경계가 아닌 배포 단위를 모델링합니다.

**IAM 액세스 키 대신 OIDC를 선택한 이유**  
CI 시크릿에 저장된 장기 자격증명은 일반적인 침해 경로입니다. OIDC 토큰은 단기 유효(단일 작업 실행)하며 특정 레포지토리와 브랜치로 범위가 제한되어 탈취 및 악용이 훨씬 어렵습니다.
