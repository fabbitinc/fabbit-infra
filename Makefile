.PHONY: help fmt validate \
	init-prod-edge plan-prod-edge apply-prod-edge \
	init-prod-storage plan-prod-storage apply-prod-storage

ifneq (,$(wildcard .env))
include .env
export
endif

EDGE_DIR := live/prod/edge
STORAGE_DIR := live/prod/storage

help:
	@echo "사용 가능한 명령:"
	@echo "  make init-prod-edge"
	@echo "  make plan-prod-edge"
	@echo "  make apply-prod-edge"
	@echo "  make init-prod-storage"
	@echo "  make plan-prod-storage"
	@echo "  make apply-prod-storage"
	@echo "  make validate"
	@echo "  make fmt"

init-prod-edge:
	cd $(EDGE_DIR) && tofu init

plan-prod-edge:
	cd $(EDGE_DIR) && tofu plan

apply-prod-edge:
	cd $(EDGE_DIR) && tofu apply

destroy-prod-edge:
	cd $(EDGE_DIR) && tofu destroy

init-prod-storage:
	cd $(STORAGE_DIR) && tofu init

plan-prod-storage:
	cd $(STORAGE_DIR) && tofu plan

apply-prod-storage:
	cd $(STORAGE_DIR) && tofu apply

destroy-prod-storage:
	cd $(STORAGE_DIR) && tofu destroy

validate:
	cd $(EDGE_DIR) && tofu init -backend=false && tofu validate
	cd $(STORAGE_DIR) && tofu init -backend=false && tofu validate

fmt:
	tofu fmt -recursive
