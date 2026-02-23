# AWS 인프라 관리
# 사용법:
#   make init
#   make plan ENV=dev
#   make apply ENV=prod
#   make output ENV=dev
#   make destroy ENV=dev

init:
	tofu init

plan:
	@test -n "$(ENV)" || (echo "ERROR: ENV 필요 (dev, prod)" && exit 1)
	tofu plan \
		-var-file=envs/$(ENV).tfvars \
		-var-file=envs/$(ENV).secrets.tfvars \
		-state=envs/$(ENV).tfstate

apply:
	@test -n "$(ENV)" || (echo "ERROR: ENV 필요 (dev, prod)" && exit 1)
	tofu apply \
		-var-file=envs/$(ENV).tfvars \
		-var-file=envs/$(ENV).secrets.tfvars \
		-state=envs/$(ENV).tfstate

output:
	@test -n "$(ENV)" || (echo "ERROR: ENV 필요 (dev, prod)" && exit 1)
	tofu output \
		-state=envs/$(ENV).tfstate

destroy:
	@test -n "$(ENV)" || (echo "ERROR: ENV 필요 (dev, prod)" && exit 1)
	tofu destroy \
		-var-file=envs/$(ENV).tfvars \
		-var-file=envs/$(ENV).secrets.tfvars \
		-state=envs/$(ENV).tfstate

.PHONY: init plan apply output destroy
