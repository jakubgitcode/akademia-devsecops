// =====================================================
// Terratest — testy integracyjne dla przyklad_blok4/infra
//
// Dwa poziomy testów:
//   - TestTerraformPlanOnly: nie wymaga Azure (plan offline)
//   - TestTerraformApplyAndVerify: pełny deploy + weryfikacja
// =====================================================

package test

import (
	"context"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func terraformAuthEnv() map[string]string {
	env := map[string]string{}

	passThrough := []string{
		"ARM_CLIENT_ID",
		"ARM_TENANT_ID",
		"ARM_SUBSCRIPTION_ID",
		"ARM_USE_OIDC",
		"ARM_USE_AZUREAD",
		"ARM_USE_CLI",
		"ACTIONS_ID_TOKEN_REQUEST_URL",
		"ACTIONS_ID_TOKEN_REQUEST_TOKEN",
	}

	for _, key := range passThrough {
		if value := os.Getenv(key); value != "" {
			env[key] = value
		}
	}

	// Fallback aliasing for Terraform versions that read ARM_OIDC_* names.
	if env["ARM_OIDC_REQUEST_URL"] == "" && env["ACTIONS_ID_TOKEN_REQUEST_URL"] != "" {
		env["ARM_OIDC_REQUEST_URL"] = env["ACTIONS_ID_TOKEN_REQUEST_URL"]
	}
	if env["ARM_OIDC_REQUEST_TOKEN"] == "" && env["ACTIONS_ID_TOKEN_REQUEST_TOKEN"] != "" {
		env["ARM_OIDC_REQUEST_TOKEN"] = env["ACTIONS_ID_TOKEN_REQUEST_TOKEN"]
	}

	// Keep backend auth mode deterministic in CI.
	if env["ARM_USE_OIDC"] == "" {
		env["ARM_USE_OIDC"] = "true"
	}
	if env["ARM_USE_AZUREAD"] == "" {
		env["ARM_USE_AZUREAD"] = "true"
	}
	if env["ARM_USE_CLI"] == "" {
		env["ARM_USE_CLI"] = "false"
	}

	return env
}

// =====================================================
// Test 1: Plan-only (bez deploymentu)
//
// Weryfikuje, że konfiguracja jest poprawna składniowo,
// plan generuje oczekiwane zasoby i nie ma błędów.
// Wymaga backendu azurerm; jeśli brak ARM_* env, test jest pomijany.
// =====================================================
func TestTerraformPlanOnly(t *testing.T) {
	t.Parallel()

	if os.Getenv("ARM_CLIENT_ID") == "" || os.Getenv("ARM_TENANT_ID") == "" || os.Getenv("ARM_SUBSCRIPTION_ID") == "" {
		t.Skip("Brak ARM_* credentials — pomijam TestTerraformPlanOnly (backend azurerm)")
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../infra",
		VarFiles:     []string{"environments/dev.tfvars"},
		PlanFilePath: "dev.tfplan",
		NoColor:      true,
		EnvVars:      terraformAuthEnv(),
	})

	// Init + Plan (nie aplikuje)
	planStruct := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// Weryfikacja zaplanowanych zasobów
	resourceTypes := make(map[string]bool)
	for _, resource := range planStruct.RawPlan.PlannedValues.RootModule.Resources {
		resourceTypes[resource.Type] = true
	}

	assert.True(t, resourceTypes["azurerm_resource_group"], "Plan powinien zawierać resource group")
	assert.True(t, resourceTypes["azurerm_virtual_network"], "Plan powinien zawierać virtual network")
	assert.True(t, resourceTypes["azurerm_network_security_group"], "Plan powinien zawierać NSG")
	assert.True(t, resourceTypes["azurerm_storage_account"], "Plan powinien zawierać storage account")

	// Sprawdź, że plan chce utworzyć zasoby (nie jest pusty)
	resourceCount := len(planStruct.RawPlan.PlannedValues.RootModule.Resources)
	assert.GreaterOrEqual(t, resourceCount, 4, "Plan powinien tworzyć co najmniej 4 zasoby")

	// Sprawdź, że subnet z kluczem "app" (for_each) jest zaplanowany.
	hasSubnetResource := false
	hasAppSubnet := false
	for _, resource := range planStruct.RawPlan.PlannedValues.RootModule.Resources {
		if resource.Type != "azurerm_subnet" {
			continue
		}

		hasSubnetResource = true
		if strings.Contains(resource.Address, "[\"app\"]") {
			hasAppSubnet = true
			break
		}

		if name, ok := resource.AttributeValues["name"].(string); ok && name == "snet-app" {
			hasAppSubnet = true
			break
		}
	}

	assert.True(t, hasSubnetResource, "Plan powinien zawierać co najmniej jeden subnet")
	assert.True(t, hasAppSubnet, "Powinien zaplanować subnet z dev.tfvars (app)")
}

// =====================================================
// Test 2: Apply + weryfikacja w Azure
//
// Pełny cykl: apply → sprawdź outputy → sprawdź zasoby
// w Azure → destroy.
// WYMAGA Azure credentials (OIDC lub SP).
// =====================================================
func TestTerraformApplyAndVerify(t *testing.T) {
	t.Parallel()

	// Pomiń jeśli brak credentials
	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("Brak ARM_SUBSCRIPTION_ID — test pomijany (wymaga Azure)")
	}

	// Unikalna nazwa projektu, żeby uniknąć kolizji
	uniqueID := random.UniqueId()
	projectName := fmt.Sprintf("test%s", uniqueID)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../infra",
		Vars: map[string]interface{}{
			"environment":  "dev",
			"project_name": projectName,
			"location":     "Poland Central",
			"vnet_address_space": []string{"10.10.0.0/16"},
			"subnets": map[string]interface{}{
				"app": map[string]interface{}{
					"address_prefixes":  []string{"10.10.1.0/24"},
					"service_endpoints": []string{"Microsoft.Storage"},
				},
			},
			"storage_account_tier":     "Standard",
			"storage_replication_type": "LRS",
			"tags": map[string]interface{}{
				"TestID": uniqueID,
			},
		},
		// Backend lokalny dla testów
		BackendConfig: map[string]interface{}{},
		NoColor:       true,
		EnvVars:       terraformAuthEnv(),
	})

	// Cleanup — destroy po zakończeniu testów
	defer terraform.Destroy(t, terraformOptions)

	// Apply
	terraform.InitAndApply(t, terraformOptions)

	// ----- Weryfikacja Terraform Outputs -----
	t.Run("outputs", func(t *testing.T) {
		rgName := terraform.Output(t, terraformOptions, "resource_group_name")
		assert.Contains(t, rgName, projectName,
			"Resource group name powinien zawierać project_name")

		vnetID := terraform.Output(t, terraformOptions, "vnet_id")
		assert.NotEmpty(t, vnetID, "VNET ID nie powinien być pusty")

		storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
		assert.NotEmpty(t, storageAccountName, "Storage account name nie powinien być pusty")
		assert.LessOrEqual(t, len(storageAccountName), 24,
			"Storage account name nie może przekraczać 24 znaków")

		subnetIDs := terraform.OutputMap(t, terraformOptions, "subnet_ids")
		assert.Contains(t, subnetIDs, "app", "Subnet 'app' powinien istnieć w outputach")
	})

	// ----- Weryfikacja zasobów w Azure -----
	t.Run("azure_resources", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
		defer cancel()

		rgName := terraform.Output(t, terraformOptions, "resource_group_name")

		// Sprawdź Resource Group
		rgExists := azure.ResourceGroupExistsContext(t, ctx, rgName, subscriptionID)
		require.True(t, rgExists, "Resource group powinien istnieć w Azure")

		// Sprawdź, że RG jest we właściwej lokalizacji
		rg := azure.GetAResourceGroupContext(t, ctx, rgName, subscriptionID)
		assert.Equal(t, "polandcentral", *rg.Location,
			"Resource group powinien być w Poland Central")

		// Sprawdź Virtual Network
		vnetName := fmt.Sprintf("vnet-%s-dev", projectName)
		vnetExists := azure.VirtualNetworkExistsContext(t, ctx, vnetName, rgName, subscriptionID)
		assert.True(t, vnetExists, "Virtual Network powinien istnieć w Azure")

		// Sprawdź Subnet
		subnetExists := azure.SubnetExistsContext(t, ctx, "snet-app", vnetName, rgName, subscriptionID)
		assert.True(t, subnetExists, "Subnet snet-app powinien istnieć w Azure")
	})

	// ----- Test idempotentności -----
	t.Run("idempotent", func(t *testing.T) {
		// Drugi apply nie powinien zmieniać niczego
		exitCode := terraform.PlanExitCode(t, terraformOptions)
		assert.Equal(t, 0, exitCode,
			"Terraform plan po apply nie powinien pokazywać zmian (idempotentność)")
	})
}
