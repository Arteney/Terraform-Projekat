module "main-vpc" {
  source     = "../Modules/Network"
  ENV        = "prod"
  AWS_REGION = var.AWS_REGION
}

module "instances" {
  source         = "../Modules/Instance"
  ENV            = "prod"
  vpc_id         = module.main-vpc.vpc_id
  public_subnets = module.main-vpc.public_subnets
}

module "DB" {
  source = "../Modules/mysql-db"

  apply-immediately      = true
  db-name                = "db-prod"
  db-subnet-group-name   = module.main-vpc.db-subnet-group-name
  identifier             = "db-prod"
  password               = var.db-password
  publicly-accessible    = false
  username               = var.db-username
  vpc-security-group-ids = [module.instances.vpc-security-group-ids]
}