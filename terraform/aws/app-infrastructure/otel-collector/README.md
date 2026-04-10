# OTEL Collector — IRSA Module

Creates IAM resources for the Splunk OpenTelemetry Collector to write container logs to S3 via IRSA.

Replaces the FluentBit module for environments migrating to OTEL (ref: DEV-217).

## Description

This module creates:
- An IAM policy granting `s3:PutObject` and `s3:GetBucketLocation` to a specific S3 bucket
- An IAM role with OIDC trust for the OTEL collector's Kubernetes ServiceAccount
- A policy attachment linking the two

The Helm chart deployment is handled separately — see [NEDSS-Helm/charts/splunk-otel-collector](https://github.com/CDCgov/NEDSS-Helm/tree/main/charts/splunk-otel-collector).

## Usage

```hcl
module "otel_collector" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/otel-collector"

  resource_prefix   = "cdc-nbs"
  s3_bucket_arn     = module.otel_logs_bucket.bucket_arn
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.cluster_oidc_issuer_url
  tags              = var.tags
}
```

Then pass the role ARN to the Helm deploy:

```bash
helm install splunk-otel-collector \
  splunk-otel-collector-chart/splunk-otel-collector \
  -f values.yaml \
  --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=${module.otel_collector.otel_collector_role_arn}" \
  -n observability --create-namespace --skip-schema-validation
```

## Values

| Key | Type | Default | Description |
|---|---|---|---|
| `resource_prefix` | string | `"cdc-nbs"` | Prefix for resource names |
| `s3_bucket_arn` | string | (required) | ARN of the S3 bucket for log storage |
| `oidc_provider_arn` | string | (required) | ARN of the EKS cluster OIDC provider |
| `oidc_provider_url` | string | (required) | URL of the EKS cluster OIDC provider |
| `namespace_name` | string | `"observability"` | Kubernetes namespace for the OTEL collector |
| `service_account_name` | string | `"splunk-otel-collector"` | ServiceAccount name used by the OTEL chart |
| `tags` | map(string) | (required) | Tags applied to all resources |

## Outputs

| Key | Description |
|---|---|
| `otel_collector_role_arn` | IAM role ARN to pass to the Helm chart via `--set` |
