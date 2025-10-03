locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "vpc" {
  source               = "./modules/vpc"
  name_prefix          = local.name_prefix
  cidr_block           = "10.20.0.0/16"
  public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
}
module "vpc_endpoints" {
  source     = "./modules/vpc_endpoints"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  sg_id      = module.vpc.default_sg_id
}
module "s3_data_lake" {
  source      = "./modules/s3_data_lake"
  name_prefix = local.name_prefix
}
module "iam" {
  source         = "./modules/iam"
  name_prefix    = local.name_prefix
  s3_bucket_arn  = module.s3_data_lake.bucket_arn
  s3_bucket_name = module.s3_data_lake.bucket_name
  vpc_id         = module.vpc.vpc_id
}
module "rds" {
  source             = "./modules/rds_postgres"
  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_instance_class  = var.db_instance_class
  db_name            = var.db_name
  master_username    = var.db_username
}

# Security groups for lambda + ec2 to reach DB
resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type                     = "ingress"
  security_group_id        = module.rds.sg_id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.iam.lambda_sg_id
}

resource "aws_security_group_rule" "allow_ec2_to_rds" {
  type                     = "ingress"
  security_group_id        = module.rds.sg_id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.ec2_k3s.sg_id
}

module "lambda_ingest_api" {
  source             = "./modules/lambda_ingest_api"
  name_prefix        = local.name_prefix
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  lambda_role_arn    = module.iam.lambda_role_arn
  lambda_sg_id       = module.iam.lambda_sg_id
  s3_bucket_name     = module.s3_data_lake.bucket_name
  db_secret_arn      = module.rds.secret_arn
}

module "ec2_k3s" {
  source                = "./modules/ec2_k3s"
  name_prefix           = local.name_prefix
  subnet_id             = module.vpc.public_subnet_ids[0]
  vpc_id                = module.vpc.vpc_id
  instance_profile_name = module.iam.ec2_instance_profile_name
}


