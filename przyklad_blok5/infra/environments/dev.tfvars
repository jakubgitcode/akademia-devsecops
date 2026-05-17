environment = "dev"
location    = "Poland Central"

vnet_address_space = ["10.10.0.0/16"]

subnets = {
  app = {
    address_prefixes = ["10.10.1.0/24"]
  }
  db = {
    address_prefixes = ["10.10.2.0/24"]
  }
  test = {
    address_prefixes = ["10.10.3.0/24"]
  }
}

tags = {
  Owner      = "team-dev"
  CostCenter = "CC-1234"
}
