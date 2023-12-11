# Deploying AWS Resource with Terraform

## Description

Module to add synthetic check, cloudwatch events, an sns topic and email alerts
Note: emails need to be confirmed before they will actually receive alerts,
internal confirmation emails seem to get caught in spam filter, until those
are tuned consider gmail addresses initially then manually add emails to
corresponding sns topics

## Values

Below are the available Variables contained within this EFS module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
synthetics_canary_email_addresses |  list(string) | | list of emails to send alerts
synthetics_canary_url | string | | url to monitor
synthetics_canary_bucket_name | string | | bucket to save results of check


## TODO
Make URLs a list instead of a single value

Consider using email address list outside of cloudwatch synthetics for
other SNS topics


# apply manually outside of pipeline
terraform plan -var-file=inputs.tfvars -var 'synthetics_canary_create=true'
terraform apply -var-file=inputs.tfvars -var 'synthetics_canary_create=true'
