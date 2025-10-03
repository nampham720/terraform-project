output "lambda_role_arn"          { value = aws_iam_role.lambda.arn }
output "lambda_sg_id"             { value = aws_security_group.lambda.id }
output "ec2_instance_profile_name"{ value = aws_iam_instance_profile.ec2.name }

