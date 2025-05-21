output "sns_topic_arn" {
  value = aws_sns_topic.split_csv_topic.arn
}
