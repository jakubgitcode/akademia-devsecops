locals {
  resource_name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Pipeline    = "github-actions"
  })

  # Storage account name: max 24 chars, lowercase, no hyphens
  storage_account_name = lower(replace("st${var.project_name}${var.environment}", "-", ""))
}
