output "api_endpoint_url" { value = module.lambda_ingest_api.api_url }
output "s3_bucket_name" { value = module.s3_data_lake.bucket_name }
output "rds_endpoint" { value = module.rds.endpoint }
output "rds_secret_arn" { value = module.rds.secret_arn }
output "ec2_k3s_public_ip" { value = module.ec2_k3s.public_ip }
output "ec2_instance_id" { value = module.ec2_k3s.instance_id }

# api_endpoint_url = "https://6uplqd2qp1.execute-api.eu-north-1.amazonaws.com"
# ec2_k3s_public_ip = "16.170.148.208"
# rds_endpoint = "chat-pipeline-dev-pg.cbqeoym4edkb.eu-north-1.rds.amazonaws.com"
# rds_secret_arn = "arn:aws:secretsmanager:eu-north-1:672818178341:secret:chat-pipeline-dev/rds/postgres-QpbYAD"
# s3_bucket_name = "chat-pipeline-dev-datalake-59b5cee6"
# instance_id = i-037cfa47564ffd185