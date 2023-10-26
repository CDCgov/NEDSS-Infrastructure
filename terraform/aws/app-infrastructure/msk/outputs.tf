output "bootstrap_brokers" {
  description = "The bootstrap brokers for the MSK cluster"
  value       = aws_msk_cluster.this.bootstrap_brokers
}

output "zookeeper_connect_string" {
  description = "The Zookeeper connect string for the MSK cluster"
  value       = aws_msk_cluster.this.zookeeper_connect_string
}