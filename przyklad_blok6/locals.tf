locals {
  resource_name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    PatchGroup  = "${var.environment}-scheduled"
  })

  # Generuj nazwy VM
  vm_names = { for i in range(var.vm_count) : "vm-${i + 1}" => i }
}
