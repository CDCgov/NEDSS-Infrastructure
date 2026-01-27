resource "aws_secretsmanager_secret" "grafana_token" {
  name                    = "${var.resource_prefix}-grafana-sa-token"
  description             = "Grafana service account token for Terraform"
  recovery_window_in_days = 0 # Set to 0 for immediate deletion, or 7-30 for recovery window

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-grafana-sa-token"
    }
  )
}

# Initial placeholder value - Lambda will populate the actual token on first run
resource "aws_secretsmanager_secret_version" "grafana_token_initial" {
  secret_id = aws_secretsmanager_secret.grafana_token.id
  secret_string = jsonencode({
    token      = "placeholder-will-be-rotated-by-lambda"
    created_at = timestamp()
  })

  lifecycle {
    ignore_changes = [secret_string] # Lambda manages this after initial creation
  }
}