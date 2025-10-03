output "instance_id" { value = aws_instance.k3s.id }
output "public_ip"   { value = aws_instance.k3s.public_ip }
output "sg_id"       { value = aws_security_group.ec2.id }

