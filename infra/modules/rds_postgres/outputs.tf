
output "endpoint"  { value = aws_db_instance.this.address }
output "sg_id"     { value = aws_security_group.rds_sg.id }
output "secret_arn"{ value = aws_secretsmanager_secret.db.arn }

