data "aws_ami" "amazonlinux2" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "No inbound; outbound all"
  vpc_id      = var.vpc_id
  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
    }
  tags = { Name = "${var.name_prefix}-ec2-sg" }
}
resource "aws_instance" "k3s" {
  ami                         = data.aws_ami.amazonlinux2.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  iam_instance_profile        = var.instance_profile_name
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  user_data = <<EOF
    #!/bin/bash
    set -euo pipefail

    log() { echo "[$(date -Is)] $*"; }

    # Update system
    sudo yum update -y

    # Install Python 3 and pip
    sudo yum install -y python3 python3-pip

    # Upgrade pip
    sudo python3 -m pip install --upgrade pip

    # Install PostgreSQL client libs (for psycopg2, etc.)
    sudo yum install -y postgresql postgresql-devel gcc


    EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    delete_on_termination = true
  }
  tags = { Name = "${var.name_prefix}-k3s" }
}
