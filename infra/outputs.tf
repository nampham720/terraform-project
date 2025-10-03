output "api_endpoint_url" { value = module.lambda_ingest_api.api_url }
output "s3_bucket_name" { value = module.s3_data_lake.bucket_name }
output "rds_endpoint" { value = module.rds.endpoint }
output "rds_secret_arn" { value = module.rds.secret_arn }
output "ec2_k3s_public_ip" { value = module.ec2_k3s.public_ip }
output "ec2_instance_id" { value = module.ec2_k3s.instance_id }
