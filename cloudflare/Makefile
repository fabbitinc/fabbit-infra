# Cloudflare 인프라 관리
# 사용법:
#   make web-plan ENV=dev
#   make web-apply ENV=prod
#   make web-output ENV=prod
#   make redirects-plan
#   make redirects-apply

# --- Web (R2) ---
# ENV 필수: dev, prod

web-init:
	cd web && tofu init

web-plan:
	@test -n "$(ENV)" || (echo "ERROR: ENV 필요 (dev, prod)" && exit 1)
	cd web && tofu plan \
		-var-file=envs/$(ENV).tfvars \
		-var-file=envs/$(ENV).secrets.tfvars \
		-state=envs/$(ENV).tfstate

web-apply:
	@test -n "$(ENV)" || (echo "ERROR: ENV 필요 (dev, prod)" && exit 1)
	cd web && tofu apply \
		-var-file=envs/$(ENV).tfvars \
		-var-file=envs/$(ENV).secrets.tfvars \
		-state=envs/$(ENV).tfstate

web-output:
	@test -n "$(ENV)" || (echo "ERROR: ENV 필요 (dev, prod)" && exit 1)
	cd web && tofu output \
		-state=envs/$(ENV).tfstate

# --- Redirects (Bulk Redirect) ---

redirects-init:
	cd redirects && tofu init

redirects-plan:
	cd redirects && tofu plan \
		-var-file=envs/prod.tfvars \
		-var-file=envs/prod.secrets.tfvars \
		-state=envs/redirects.tfstate

redirects-apply:
	cd redirects && tofu apply \
		-var-file=envs/prod.tfvars \
		-var-file=envs/prod.secrets.tfvars \
		-state=envs/redirects.tfstate

redirects-output:
	cd redirects && tofu output \
		-state=envs/redirects.tfstate

.PHONY: web-init web-plan web-apply web-output \
        redirects-init redirects-plan redirects-apply redirects-output
