
output "s3_endpoint_id"             { value = aws_vpc_endpoint.s3.id }
output "secretsmanager_endpoint_id" { value = aws_vpc_endpoint.secretsmanager.id }
output "kms_endpoint_id"            { value = aws_vpc_endpoint.kms.id }
