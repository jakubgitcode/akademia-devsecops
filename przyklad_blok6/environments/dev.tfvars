environment = "dev"
location    = "West Europe"

# VM — mniejsze i tańsze w dev
vm_size  = "Standard_B2as_v2"
vm_count = 1

# Patching — częstsze, agresywne
patch_window_start      = "2024-01-01 02:00"
patch_window_duration   = "03:55"
patch_window_recurrence = "1Week Wednesday"
patch_reboot_policy     = "Always"

patch_linux_classifications   = ["Critical", "Security", "Other"]
patch_windows_classifications = ["Critical", "Security", "UpdateRollup", "Definition", "Updates"]

# Dynamic scope wyłączony — mało VM w dev
enable_dynamic_scope = false

tags = {
  Owner      = "team-dev"
  CostCenter = "CC-DEV"
}
