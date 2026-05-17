environment = "test"
location    = "Poland Central"

vnet_address_space = ["10.20.0.0/16"]

subnets = {
  app = {
    address_prefixes  = ["10.20.1.0/24"]
    service_endpoints = ["Microsoft.Storage"]
  }
  db = {
    address_prefixes  = ["10.20.2.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
  }
}

storage_account_tier     = "Standard"
storage_replication_type = "LRS"

tags = {
  Owner      = "team-qa"
  CostCenter = "CC-TEST"
}
