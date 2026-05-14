# Example backend config for AzureRM backend
# Usage:
#   terraform init -backend-config=backend.hcl

# Required
storage_account_name = "tflab1sac5c5x0"
container_name       = "mojstan"
key                  = "lab2.terraform.tfstate"

# Optional when lookup of blob endpoint is needed (see docs)
resource_group_name  = "tf-lab1-rgc5c5x0"
# subscription_id      = "<sub-id>"
# tenant_id            = "<tenant-id>"
use_azuread_auth     = true
# use_cli              = true
# use_oidc             = true
# lookup_blob_endpoint = false
