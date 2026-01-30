terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

locals {
  project     = "fabbit"
  environment = "prod"
  location    = var.location

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "OpenTofu"
  }
}

module "resource_group" {
  source = "../../modules/resource-group"

  name     = "rg-${local.project}-${local.environment}"
  location = local.location
  tags     = local.common_tags
}

module "key_vault" {
  source = "../../modules/key-vault"

  name                = "kv-${local.project}-${local.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  purge_protection_enabled = true

  secrets = {
    "postgresql-password"   = var.postgresql_password
    "openai-api-key"        = var.openai_api_key
    "r2-access-key-id"      = var.r2_access_key_id
    "r2-secret-access-key"  = var.r2_secret_access_key
  }

  tags = local.common_tags
}

module "postgresql" {
  source = "../../modules/postgresql"

  name                = "psql-${local.project}-${local.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  administrator_login    = var.postgresql_admin_login
  administrator_password = var.postgresql_password
  database_name          = "fabbit"

  sku_name   = "GP_Standard_D2s_v3"
  storage_mb = 65536

  backup_retention_days        = 14
  geo_redundant_backup_enabled = true

  allow_azure_services = true

  tags = local.common_tags
}

module "container_registry" {
  source = "../../modules/container-registry"

  name                = "cr${local.project}${local.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"

  tags = local.common_tags
}

module "container_app" {
  source = "../../modules/container-apps"

  name                = "ca-${local.project}-api-${local.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  container_name  = "api"
  container_image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
  cpu             = 1.0
  memory          = "2Gi"
  target_port     = 8000

  min_replicas       = 1
  max_replicas       = 10
  log_retention_days = 90

  container_registry_server               = module.container_registry.login_server
  container_registry_username             = module.container_registry.admin_username
  container_registry_password_secret_name = "registry-password"

  secrets = {
    "registry-password"      = module.container_registry.admin_password
    "database-url"           = module.postgresql.connection_string
    "openai-api-key"         = var.openai_api_key
    "r2-access-key-id"       = var.r2_access_key_id
    "r2-secret-access-key"   = var.r2_secret_access_key
  }

  environment_variables = {
    "DATABASE_URL" = {
      secret_name = "database-url"
    }
    "OPENAI_API_KEY" = {
      secret_name = "openai-api-key"
    }
    "S3_ENDPOINT_URL" = {
      value = var.r2_endpoint_url
    }
    "S3_BUCKET_NAME" = {
      value = var.r2_bucket_name
    }
    "S3_ACCESS_KEY_ID" = {
      secret_name = "r2-access-key-id"
    }
    "S3_SECRET_ACCESS_KEY" = {
      secret_name = "r2-secret-access-key"
    }
    "S3_REGION" = {
      value = "auto"
    }
  }

  tags = local.common_tags
}
