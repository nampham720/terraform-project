resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-dbsubnet"
  subnet_ids = var.private_subnet_ids
}
resource "aws_security_group" "ec2_sg" {
  name   = "${var.name_prefix}-ec2-sg-1"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH access (adjust for security)
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "rds_sg" {
  name        = "${var.name_prefix}-rds-sg-1"
  description = "Allow DB connections from EC2"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "random_password" "db" {
  length  = 16
  special = true
  override_special = "!#$%&()*+,-.:;<=>?[]^_{|}~"
}
resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.name_prefix}/rds/postgres"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.master_username,
    password = random_password.db.result,
    engine   = "postgres",
    host     = "", # will be updated later
    port     = 5432,
    dbname   = var.db_name
  })
}
resource "aws_db_instance" "this" {
  identifier              = "${var.name_prefix}-pg"
  engine                  = "postgres"
  engine_version          = "17.4" # Free Tier-compatible version
  instance_class          = "db.t3.micro" # Free Tier eligible
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_name                 = var.db_name
  username                = var.master_username
  password                = random_password.db.result
  multi_az                = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0
  deletion_protection     = false
}
resource "aws_secretsmanager_secret_version" "db_update" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.master_username,
    password = random_password.db.result,
    engine   = "postgres",
    host     = aws_db_instance.this.address,
    port     = 5432,
    dbname   = var.db_name
  })
  depends_on = [aws_db_instance.this]
}


