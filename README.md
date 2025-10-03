# Data Pipeline with Terraform, IAM, S3, Cloudwatch, Lambda, RDS (PostgreSQL), VPC

This project demonstrates Terraform skills in setting up Infrastructure in Cloud Platform (AWS Free tier) and storing data into RDS. 

Furthermore, it also includes Ingesting raw data to RDS => Transform raw data => Curate transformed data to test if the infrastructure is working as expected. 

The goal of this is to highlight **Terraform skills**

---

## Architecture Overview

<pre lang="markdown"> 
infra/ 
    └── lambda_src/
          └── handler.py -- handle POST request 
    └── modules/
        └── ec2_k3s/
        └── iam/
        └── lambda_ingest_api/
        └── rds_postgres/
        └── vpc/
        └── vpc_endpoints
    ├── main.tf 
    ├── output.tf 
    ├── providers.tf 
    ├── versions.tf 
    ├── variables.tf 
    ├── terraform.tfvars 
 
python/
    ├── ingest.py
    ├── transform.py
    ├── curate.py
  </pre>

---

## Terraform Services Provisioned

| Module     | Purpose |
| ---      | ---       |
| ec2_k3s |    Provisions an EC2 instance running K3s (lightweight Kubernetes - currently not required k8s)      |
| iam/     |  Defines IAM roles and policies (for Lambda, EC2, RDS access, S3, etc.)       |
| lambda_ingest_api/     |  Deploys a Lambda function and API Gateway to ingest raw data into RDS       |
| rds_postgres/     |  Sets up a PostgreSQL database on Amazon RDS       |
| vpc/     |  Creates a custom Virtual Private Cloud with public and private subnets       |
| vpc_endpoints/     |  Adds VPC endpoints for secure, private access to AWS services      |

---

## Usage
1. **Register your AWS account Free-tier**
2. **Set up AWS credentials**
```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=...
```

3. **Initialize Terraform**
```bash
cd infra/
terraform init
```

4. **Plan deployment**
```bash
terraform plan
```

5. **Apply configuration**
```bash
terraform apply -auto-approve
```
For easier, please copy the outputs returned in terminal once terraform finishes applying the infrastructure. 

6. **Destroy resources when done**
```bash
terraform destroy -auto-approve
```

---

## Testing Infra
Assumption: still residing in infra/
1. **Run the ingest.py**
```bash
python3 ../python/ingest.py
```
2. **Run transform.py**
```bash
python3 ../python/transform.py
```
3. **SSH to EC2**
```bash
aws ssm start-session --target <your EC2-id>
```
4. **Create curate.py in /tmp**
```bash
cd /tmp
vim curate.py
```
Copy the content of python/curate.py to /tmp/curate.py

5. **Run curate.py in /tmp**
```bash
python3 curate.py
```

You may need to install these libraries in EC2:
* pip install -q boto3 psycopg2-binary 

