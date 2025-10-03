variable "name_prefix"       { type = string }
variable "private_subnet_ids"{ type = list(string) }
variable "vpc_id"            { type = string }
variable "lambda_role_arn"   { type = string }
variable "lambda_sg_id"      { type = string }
variable "s3_bucket_name"    { type = string }
variable "db_secret_arn"     { type = string }
