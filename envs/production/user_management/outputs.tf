output "users_table" {
  description = "The name of the DynamoDB table for users"
  value       = aws_dynamodb_table.users_table.name
}

output "users_table_arn" {
  description = "The ARN of the DynamoDB table for users"
  value       = aws_dynamodb_table.users_table.arn
}

output "users_table_stream_arn" {
  description = "The stream ARN of the DynamoDB table for users"
  value       = aws_dynamodb_table.users_table.stream_arn
}

output "event_bus_arn" {
  description = "The ARN of the CloudWatch Event Bus for user management"
  value       = aws_cloudwatch_event_bus.user_management.arn
}
