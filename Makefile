.PHONY: help fmt validate \
	init-prod-frontend plan-prod-frontend apply-prod-frontend \
	init-prod-storage plan-prod-storage apply-prod-storage

ifneq (,$(wildcard .env))
include .env
export
endif

FRONTEND_DIR := live/prod/frontend
STORAGE_DIR := live/prod/storage

help:
	@echo "사용 가능한 명령:"
	@echo "  make init-prod-frontend"
	@echo "  make plan-prod-frontend"
	@echo "  make apply-prod-frontend"
	@echo "  make init-prod-storage"
	@echo "  make plan-prod-storage"
	@echo "  make apply-prod-storage"
	@echo "  make validate"
	@echo "  make fmt"

init-prod-frontend:
	cd $(FRONTEND_DIR) && tofu init

plan-prod-frontend:
	cd $(FRONTEND_DIR) && tofu plan

apply-prod-frontend:
	cd $(FRONTEND_DIR) && tofu apply

init-prod-storage:
	cd $(STORAGE_DIR) && tofu init

plan-prod-storage:
	cd $(STORAGE_DIR) && tofu plan

apply-prod-storage:
	cd $(STORAGE_DIR) && tofu apply

validate:
	cd $(FRONTEND_DIR) && tofu init -backend=false && tofu validate
	cd $(STORAGE_DIR) && tofu init -backend=false && tofu validate

fmt:
	tofu fmt -recursive
