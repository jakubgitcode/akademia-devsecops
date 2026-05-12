#!/bin/bash
set -euo pipefail

# Usage: ./skrypt.sh [-f varfile]
# Examples:
#   ./skrypt.sh
#   ./skrypt.sh -f dev.tfvars

VAR_FILE=""
if [[ ${1:-} == "-f" || ${1:-} == "--var-file" ]]; then
  VAR_FILE="-var-file=${2:-}"
  shift 2
fi

terraform init
terraform fmt -check
terraform validate
terraform plan ${VAR_FILE}
terraform apply -auto-approve ${VAR_FILE}

echo "Output deployment_id:"
terraform output deployment_id || true

echo "Output deployment_config:"
terraform output deployment_config || true

echo "Sensitive output api_token (redacted by Terraform):"
terraform output api_token || true
