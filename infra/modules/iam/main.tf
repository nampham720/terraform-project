
# Lambda execution role
resource "aws_iam_role" "lambda" {
  name = "${var.name_prefix}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_policy" "lambda" {
  name = "${var.name_prefix}-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CloudWatch Logs
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"
        ],
        Resource: "*"
      },
      # S3 Put to data lake
      {
        Effect: "Allow",
        Action: ["s3:PutObject", "s3:PutObjectAcl"],
        Resource: "${var.s3_bucket_arn}/*"
      },
      # Read DB secret
      {
        Effect: "Allow",
        Action: ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        Resource: "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


# Lambda SG (for VPC attachment)
resource "aws_security_group" "lambda" {
  name        = "${var.name_prefix}-lambda-sg"
  description = "Lambda to RDS"
  vpc_id      = var.vpc_id # data.aws_vpc.selected.id
  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
    }
}
# data "aws_vpc" "selected" { default = true }
# Replace with explicit VPC via variable if you prefer strict scoping.
# EC2 Instance role (SSM + S3 readonly)
resource "aws_iam_role" "ec2" {
  name = "${var.name_prefix}-ec2-role"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_policy" "ec2_s3_ro" {
  name   = "${var.name_prefix}-ec2-s3-ro"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect: "Allow",
      Action: ["s3:GetObject","s3:ListBucket", "s3:PutObject"],
      Resource: [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ec2_s3_ro_attach" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_s3_ro.arn
}
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}
