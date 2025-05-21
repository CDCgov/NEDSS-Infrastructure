# CSV to HL7 Transformer Lambda (Terraform Deployment)

## What This Does

This Terraform project:
- Creates an SNS topic for notifications
- Deploys a Lambda function that converts each row in an uploaded CSV file to HL7 format
- Triggers Lambda on `.csv` uploads to the specified S3 bucket
- Publishes success/error results to SNS

## How to Use

1. Place the `lambda_csv_to_hl7.zip` file in this directory.
2. Update `terraform.tfvars` with your actual S3 bucket name.
3. Run the following:

```bash
terraform init
terraform apply
```

## Output

- HL7 files are stored in `elr/csv2hl7/` within the same bucket.
- One HL7 message per row in the CSV.
