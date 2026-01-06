output "analytics_queue_url" {
  description = "The URL of the analytics SQS queue"
  value       = aws_sqs_queue.analytics.url
}

output "analytics_queue_arn" {
  description = "The ARN of the analytics SQS queue"
  value       = aws_sqs_queue.analytics.arn
}
