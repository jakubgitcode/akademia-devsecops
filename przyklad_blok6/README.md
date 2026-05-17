# Przykład Blok 6 — Azure Update Manager + Terraform

## Opis

Kompletna konfiguracja **Azure Update Manager** przez Terraform:
- Maintenance configurations per środowisko (dev/prod)
- VM z poprawną konfiguracją patch_mode
- Static + Dynamic scope assignments
- Ring deployment strategy (canary → batch → broad)

### Zawartość

```
przyklad_blok6/
├── terraform.tf              # Provider + backend
├── variables.tf              # Zmienne (env, patch schedule, VM)
├── locals.tf                 # Tagi, prefixy nazw
├── main.tf                   # Resource Group
├── main.network.tf           # VNET + NSG + Subnet
├── main.vm.tf                # Linux VM z patch_mode = "AutomaticByPlatform"
├── main.patching.tf          # Maintenance Configuration + Assignments
├── main.policy.tf            # Azure Policy — wymuszenie compliance patching
├── outputs.tf                # Outputy
└── environments/
    ├── dev.tfvars             # Dev — częstsze patche, mniejsze VM
    └── prod.tfvars            # Prod — ring deployment, approval
```

## Kluczowe zasoby

| Zasób Terraform | Rola |
|-----------------|------|
| `azurerm_maintenance_configuration` | Definicja okna serwisowego |
| `azurerm_maintenance_assignment_virtual_machine` | Przypisanie VM (static) |
| `azurerm_maintenance_assignment_dynamic_scope` | Przypisanie dynamiczne (tag-based) |
| `azurerm_resource_group_policy_assignment` | Wymuszenie compliance |

## Diagram — Ring Deployment

```
Ring 0 (Canary)       Ring 1 (Early)       Ring 2 (Broad)
┌───────────────┐     ┌───────────┐       ┌───────────────┐
│ 1 VM dev/test │────►│ 20% fleet │──────►│ Reszta prod   │
│ Wtorek 02:00  │     │ Czw 02:00 │       │ Sobota 02:00  │
│ auto apply    │     │ auto+alert│       │ z approval    │
└───────────────┘     └───────────┘       └───────────────┘
```

## Wymagania

- Azure subscription z uprawnieniami do tworzenia VM i Maintenance resources
- OIDC skonfigurowane
- Remote backend
