environment = "prod"
location    = "West Europe"

# VM — większe, więcej instancji
vm_size  = "Standard_B2as_v2"
vm_count = 3

# Patching — 2. niedziela miesiąca (po Patch Tuesday + bufor)
patch_window_start      = "2024-01-14 02:00"
patch_window_duration   = "03:55"
patch_window_recurrence = "Month Second Sunday"
patch_reboot_policy     = "IfRequired"

# Tylko krytyczne i security
patch_linux_classifications   = ["Critical", "Security"]
patch_windows_classifications = ["Critical", "Security"]

# Dynamic scope WŁĄCZONY — nowe VM z tagami będą automatycznie objęte
enable_dynamic_scope = true

tags = {
  Owner      = "team-platform"
  CostCenter = "CC-PROD"
  Compliance = "required"
}
