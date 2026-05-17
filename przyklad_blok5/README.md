# Przykład Blok 5 — Drift Detection Pipeline + Branch Protection

## Opis

Kompletny przykład pipeline'a GitHub Actions wykrywającego **drift** w infrastrukturze Terraform oraz konfiguracji branch protection via Terraform.

### Zawartość

```
przyklad_blok5/
├── infra/
│   ├── terraform.tf          # Provider + backend
│   ├── main.tf               # Przykładowa infrastruktura (RG + VNET)
│   ├── variables.tf          # Zmienne
│   ├── outputs.tf            # Outputy
│   └── environments/
│       ├── dev.tfvars         # Parametry dev
│       └── prod.tfvars        # Parametry prod
├── .github/
│   └── workflows/
│       ├── drift-detection.yml    # Cykliczne wykrywanie driftu
│       ├── pr-plan.yml            # Plan na PR
│       └── apply-on-merge.yml     # Apply po merge do main
└── README.md
```

## Jak działa drift detection?

1. **Harmonogram** — pipeline uruchamia się codziennie o 6:00 UTC (pon–pt).
2. **`terraform plan -detailed-exitcode`** — exit code:
   - `0` = brak zmian (OK)
   - `1` = błąd konfiguracji (FAIL)
   - `2` = **DRIFT wykryty** (ostrzeżenie)
3. **Raport** — Job Summary w GitHubie + artifact z planem.
4. **Notyfikacja** — automatyczne tworzenie GitHub Issue z etykietą `drift`.

## Wymagania

- GitHub repo z OIDC do Azure (federated credentials)
- Sekrety: `AZURE_CLIENT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`
- Remote backend (Azure Storage)

## Diagram

```
[Cron 6:00 UTC] ──► terraform init ──► terraform plan -detailed-exitcode
                                              │
                    ┌─────────────────────────┼─────────────────────┐
                    │                         │                     │
                 exit 0                    exit 1                exit 2
                 (OK ✅)                  (ERROR ❌)            (DRIFT ⚠️)
                    │                         │                     │
              No action                  FAIL job             Create Issue
                                                              Upload artifact
                                                              Job Summary
```
