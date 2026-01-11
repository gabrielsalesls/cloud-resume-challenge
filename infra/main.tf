module "database" {
  source = "./modules/database"
}

module "backend" {
  source = "./modules/backend"
  
  dynamodb_table_name = module.database.table_name
  dynamodb_table_arn  = module.database.table_arn
}

module "frontend" {
  source = "./modules/frontend"

  api_gateway_endpoint = module.backend.visitors_api_url
}
