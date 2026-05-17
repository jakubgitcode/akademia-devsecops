environment = "dev"
location    = "Poland Central"

vnet_address_space = ["10.10.0.0/16"]

subnets = {
  app = {
    address_prefixes  = ["10.10.1.0/24"]
    service_endpoints = ["Microsoft.Storage"]
  }
}

# Dev: tańsze opcje
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

tags = {
  Owner      = "team-dev"
  CostCenter = "CC-DEV"
}
