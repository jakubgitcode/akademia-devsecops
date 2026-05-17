environment = "prod"
location    = "Poland Central"

vnet_address_space = ["10.20.0.0/16"]

subnets = {
  app = {
    address_prefixes = ["10.20.1.0/24"]
  }
  db = {
    address_prefixes = ["10.20.2.0/24"]
  }
  mgmt = {
    address_prefixes = ["10.20.3.0/24"]
  }
}

tags = {
  Owner      = "team-platform"
  CostCenter = "CC-5678"
  Compliance = "required"
}
