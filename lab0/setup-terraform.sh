#!/bin/bash

# Terraform Installation Script for Linux Mint / Ubuntu
# Fixes GPG key issues and installs Terraform from HashiCorp repository

set -e

echo "=== Terraform Installation for Linux Mint ==="
echo ""

# Step 1: Remove old HashiCorp repo entries to avoid apt update failures
echo "Step 1: Removing old HashiCorp repository entries (if any)..."
sudo rm -f /etc/apt/sources.list.d/hashicorp.list /etc/apt/sources.list.d/hashicorp.sources

# Step 2: Install required packages
echo "Step 2: Installing required packages..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Step 3: Add HashiCorp GPG key (fixes the NO_PUBKEY error)
echo "Step 3: Adding HashiCorp GPG key..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
sudo chmod 0644 /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Step 4: Add HashiCorp repository
echo "Step 4: Adding HashiCorp repository..."

# Detect distribution - handle Linux Mint mapping to Ubuntu
DISTRO=$(lsb_release -cs)
if [ -f /etc/linuxmint/info ]; then
    # Linux Mint detected - map to Ubuntu base
    UBUNTU_CODENAME=$(grep "UBUNTU_CODENAME=" /etc/linuxmint/info | cut -d'=' -f2)
    if [ -n "$UBUNTU_CODENAME" ]; then
        DISTRO="$UBUNTU_CODENAME"
        echo "Linux Mint detected, using Ubuntu base: $DISTRO"
    fi
fi

# Fallback mapping for Linux Mint codenames when UBUNTU_CODENAME is missing
case "$DISTRO" in
    zara)
        DISTRO="noble"
        echo "Linux Mint codename zara mapped to Ubuntu: $DISTRO"
        ;;
    wilma|xia)
        DISTRO="jammy"
        echo "Linux Mint codename $DISTRO mapped to Ubuntu: jammy"
        DISTRO="jammy"
        ;;
esac

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $DISTRO main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Step 5: Update package list again (to include new repository)
echo "Step 5: Updating package list again..."
sudo apt-get update

# Step 6: Install Terraform
echo "Step 6: Installing Terraform..."
sudo apt-get install -y terraform

# Step 7: Verify installation
echo "Step 7: Verifying Terraform installation..."
terraform version

echo ""
echo "=== Terraform installation completed successfully! ==="
echo ""
echo "You can now run the lab:"
echo "  cd $(pwd)"
echo "  terraform init"
echo "  terraform plan"
echo "  terraform apply -auto-approve"
