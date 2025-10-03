# Data Pipeline with Terraform, IAM, S3, Cloudwatch, Lambda, RDS (PostgreSQL), VPC

This project demonstrates Terraform skills in setting up Infrastructure in Cloud Platform (AWS Free tier) and storing data into RDS. 

Furthermore, it also includes Ingesting raw data to RDS => Transform raw data => Curate transformed data. 

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

1. **Producers** → Push events into **Kinesis Data Stream**.
2. **Kinesis Data Firehose** → Consumes records from the stream and delivers them to an **S3 landing bucket**.
3. **S3 Landing Bucket** → Stores raw event data partitioned by date.
4. **PySpark / EMR Cluster** → Reads raw data from S3, transforms it, and writes to a **curated S3 bucket** for analytics.
5. **Snowflake** → Reads curated data from S3 using **Snowpipe**, allowing querying and analytics.
6. **CloudWatch Logs** → Captures Firehose delivery logs for debugging.

---

## Terraform Services Provisioned

### 1. **Amazon S3**
- **Landing Bucket**: Receives raw streaming data from Firehose.
- **Curated Bucket**: Stores transformed data from PySpark, ready for Snowflake ingestion.
- Lifecycle configuration to expire objects after 90 days.

### 2. **Amazon Kinesis Data Stream**
- Receives real-time events from producers.
- Configurable shard count for throughput control.

### 3. **Amazon Kinesis Data Firehose**
- Reads from Kinesis Data Stream and writes into S3 (landing bucket).
- Uses `extended_s3_configuration` for buffer, prefix, and error handling.

### 4. **IAM Roles & Policies**
- Firehose role: Allows writing to S3 and CloudWatch logging.
- EMR service role & EC2 instance profile: Allows EMR cluster to read/write S3 and manage EMR jobs.

### 5. **Amazon EMR Cluster**
- Runs PySpark jobs for streaming transformations.
- Configured with separate MASTER and CORE instance groups using `aws_emr_instance_group`.

### 6. **CloudWatch Logs**
- Captures Firehose delivery errors and debugging logs.
- Retention period: 14 days.

---

## File Structure
```
provider.tf                # AWS provider setup
s3.tf                      # Landing & Curated S3 buckets + lifecycle
kinesis.tf                 # Kinesis data stream
firehose.tf                # Kinesis Firehose delivery stream
iam.tf                     # IAM roles and policies
emr.tf                     # EMR cluster + instance groups
cloudwatch.tf              # CloudWatch log group
variables.tf               # Terraform variable definitions
outputs.tf                 # Outputs for bucket names, stream, Firehose, EMR cluster
terraform.tfvars.json      # JSON file with values for variables
```

---

## Example terraform.tfvars.json
```json
{
  "aws_region": "eu-north-1",
  "environment": "dev",
  "suffix": "001",
  "s3_bucket_name": "kinesis-firehose-landing-bucket-demo-dev-001",
  "curated_s3_bucket_name": "snowflake-curated-bucket-demo-dev-001",
  "kinesis_stream_name": "events-stream",
  "kinesis_shard_count": 1,
  "kinesis_retention_hours": 24
}
```

---

## Usage

1. **Set up AWS credentials**
```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=eu-north-1
```

2. **Initialize Terraform**
```bash
terraform init
```

3. **Plan deployment**
```bash
terraform plan
```

4. **Apply configuration**
```bash
terraform apply
```

5. **Destroy resources when done**
```bash
terraform destroy
```

---

## Testing the Stream

### AWS CLI Producer
```bash
aws kinesis put-record \
  --stream-name events-stream \
  --partition-key key1 \
  --data "$(echo -n '{\"event\":\"hello\",\"ts\":\"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'\"}' | base64)"
```

### Python (Boto3) Producer
```python
import boto3, json
kinesis = boto3.client('kinesis', region_name='eu-north-1')
event = {'event': 'hello', 'ts': '2025-09-27T00:00:00Z'}
kinesis.put_record(StreamName='events-stream', Data=json.dumps(event), PartitionKey='pk1')
```

---

## Next Steps / Extensions
- Use **PySpark** on EMR to transform streaming data.
- Deliver curated data to **Snowflake** using Snowpipe.
- Add **CloudWatch Alarms** for monitoring Firehose and EMR job metrics.
- Optionally add **visualization layer** with Tableau, PowerBI, or Streamlit.
- Add **private VPC configuration** if you want network isolation.
