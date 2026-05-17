environment = "prod"
location    = "Poland Central"

vnet_address_space = ["10.30.0.0/16"]

subnets = {
  app = {
    address_prefixes  = ["10.30.1.0/24"]
    service_endpoints = ["Microsoft.Storage"]
  }
  db = {
    address_prefixes  = ["10.30.2.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
  }
  mgmt = {
    address_prefixes  = ["10.30.3.0/24"]
    service_endpoints = []
  }
}

# Prod: wyższa replikacja
storage_account_tier     = "Standard"
storage_replication_type = "GRS"

tags = {
  Owner      = "team-platform"
  CostCenter = "CC-PROD"
  Compliance = "required"
}
