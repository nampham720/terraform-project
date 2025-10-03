data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_region" "current" {}

# S3 Gateway endpoint (works with private subnets)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_vpc.this.main_route_table_id]
  # flatten([
  #   for id in [data.aws_vpc.this.main_route_table_id] : [id]
  # ])
}

# Interface endpoints: Secrets Manager + KMS
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.sg_id]
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "kms" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.sg_id]
  private_dns_enabled = true
}
