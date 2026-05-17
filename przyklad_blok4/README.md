# Przykład Blok 4 — Zaawansowane CI/CD: Test Pyramid + Multi-Environment Promotion

## Opis

Kompletny pipeline GitHub Actions implementujący **test pyramid dla IaC** oraz **strategię promocji** między środowiskami (dev → test → prod).

### Zawartość

```
przyklad_blok4/
├── infra/
│   ├── terraform.tf          # Provider + backend (z partial config)
│   ├── main.tf               # Zasoby (RG + Storage Account + VNET)
│   ├── variables.tf          # Zmienne z walidacją
│   ├── outputs.tf            # Outputy
│   ├── locals.tf             # Computed values
│   └── environments/
│       ├── dev.tfvars         # Dev — mały, szybki deploy
│       ├── test.tfvars        # Test — security scans + compliance
│       └── prod.tfvars        # Prod — approval required
├── .tflint.hcl               # Konfiguracja TFLint (Azure rules)
├── .trivyignore              # Ignorowane reguły Trivy (z uzasadnieniem)
├── .github/
│   └── workflows/
│       ├── ci-quality-gates.yml    # Gate 1-2: lint + security (na PR)
│       ├── cd-promote.yml          # Gate 3-4: plan + apply (multi-env)
│       └── reusable-tf-plan.yml    # Reusable workflow: terraform plan
└── README.md
```

## Test Pyramid dla IaC

```
             /\
            /  \        Integration (Terratest) — najdroższe
           /    \
          /──────\
         /        \     Security (Trivy, checkov) — średnie
        / Security \
       /────────────\
      /              \  Static Quality (tflint) — szybkie
     /   Static QA    \
    /──────────────────\
   /                    \ Syntax (fmt + validate) — natychmiastowe
  /________________________\
```

## Quality Gates

```
Code Push ──► Gate 1 ──► Gate 2 ──► Gate 3 ──► Gate 4 ──► Deploy
              │          │          │          │
              fmt        Trivy      plan       human
              validate   tflint     diff ok?   approval
              │          │          │          │
              FAIL?      FAIL?      FAIL?      REJECT?
              STOP ✗     STOP ✗     STOP ✗     STOP ✗
```

## Promotion Strategy

```
┌───────────┐         ┌───────────┐         ┌───────────┐
│    DEV    │────────►│   TEST    │────────►│   PROD    │
├───────────┤         ├───────────┤         ├───────────┤
│ auto plan │         │ plan +    │         │ plan +    │
│ auto apply│         │ security  │         │ approval  │
│           │         │ auto apply│         │ apply     │
│ dev.tfvars│         │ test.tfvars│        │ prod.tfvars│
└───────────┘         └───────────┘         └───────────┘
```

## Wymagania

- GitHub repo z OIDC do Azure (federated credentials)
- Sekrety: `AZURE_CLIENT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`
- Remote backend (Azure Storage) — osobny state key per environment
- GitHub Environments: `dev`, `test`, `production` (z approval na `production`)
