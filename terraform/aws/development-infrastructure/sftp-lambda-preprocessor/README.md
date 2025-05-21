# CSV to HL7 Transformer Lambda (Terraform Deployment)

## What This Does

This Terraform project:
- Creates three SNS topics for notifications
- Deploys three Lambda functions that 
-    converts each row in an uploaded CSV file to HL7 format
-    splits a multi HL7 message "dat" file 
-    untested code to split a multi OBR HL7 message
- Triggers Lambda on `csv,dat,hl7` uploads to the specified S3 bucket, currently the triggers are based on one users incoming directory, others can be modified/added manually
- Publishes success/error results to SNS
- subscribes an email address to SNS topics (confirm before uploading test files)

## How to Use

1. run regenerate_lambda_zips.sh to recreate zip files in build directory
2. Update `terraform.tfvars` with your actual S3 bucket name.
2. add an email address to get sns notifications
3. Run the following:

```bash
terraform init
terraform apply
```

## Output

- HL7 files are stored in `<s3bucket>/<site_name>/<username>/splitcsv, splitdat, splitobr` within the same bucket.
- One HL7 message per row in the CSV.

## TODO

- add resource prefix 
