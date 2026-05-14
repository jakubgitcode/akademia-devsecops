#!/bin/bash

set -euo pipefail

BACKEND_FILE=${BACKEND_FILE:-"backend.hcl"}

if [[ ! -f "$BACKEND_FILE" ]]; then
	echo "Missing $BACKEND_FILE. Copy backend.hcl.example and fill values first."
	exit 1
fi

# Prefer SPN login when ARM_* variables are provided.
if [[ -n "${ARM_CLIENT_ID:-}" && -n "${ARM_CLIENT_SECRET:-}" && -n "${ARM_TENANT_ID:-}" ]]; then
	echo "Azure login with Service Principal..."
	az login --service-principal \
		--username "$ARM_CLIENT_ID" \
		--password "$ARM_CLIENT_SECRET" \
		--tenant "$ARM_TENANT_ID" >/dev/null
else
	if ! az account show >/dev/null 2>&1; then
		echo "No active Azure session. Run az login or export ARM_* variables."
		exit 1
	fi
fi

#export ARM_SUBSCRIPTION_ID="6614d657-c59c-49e4-889a-fa23c3e1505b"

echo "Running terraform init with remote backend..."
terraform init -reconfigure -backend-config="$BACKEND_FILE"

echo "Running terraform fmt -check..."
terraform fmt -check

echo "Running terraform validate..."
terraform validate

echo "Running terraform plan..."
terraform plan "$@"

echo "Running terraform apply..."
terraform apply -auto-approve "$@"

echo "Remote state resources:"
terraform state list
