# Przykład Blok 7 — Terraform + Ansible + GitHub Actions Patch Pipeline

## Opis

End-to-end pipeline łączący **Terraform** (provisioning) z **Ansible** (konfiguracja i patchowanie) w **GitHub Actions**.

### Zawartość

```
przyklad_blok7/
├── infra/
│   ├── terraform.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf             # Generuje inventory YAML dla Ansible
│   └── environments/
│       └── dev.tfvars
├── ansible/
│   ├── patch_linux.yml        # Playbook: patching Linux (Debian + RHEL)
│   ├── patch_windows.yml      # Playbook: patching Windows
│   ├── rolling_update.yml     # Playbook: rolling patch z canary
│   └── ansible.cfg            # Konfiguracja Ansible
├── .github/
│   └── workflows/
│       └── patch-management.yml   # Pipeline: Terraform → Ansible
└── README.md
```

## Workflow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│  Terraform   │────►│  Inventory   │────►│   Ansible    │────►│  Raport  │
│  output      │     │  (dynamic)   │     │  playbook    │     │ artifact │
├──────────────┤     ├──────────────┤     ├──────────────┤     ├──────────┤
│ Eksportuje   │     │ Generuje     │     │ apt upgrade  │     │ JSON/TXT │
│ VM IPs       │     │ hosts.yml    │     │ health check │     │ summary  │
│ via output   │     │ z outputs TF │     │ reboot if ok │     │ pass/fail│
└──────────────┘     └──────────────┘     └──────────────┘     └──────────┘
```

## Jak uruchomić

```bash
# Dry-run (--check --diff)
gh workflow run patch-management.yml -f dry_run=true

# Pełne patchowanie
gh workflow run patch-management.yml -f dry_run=false
```
