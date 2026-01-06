module "user_management" {
  source = "./user_management"
}

output "user_management_event_bus_arn" {
  description = "The ARN of the CloudWatch Event Bus for user management"
  value       = module.user_management.event_bus_arn
}

output "user_management_users_table_name" {
  description = "The name of the DynamoDB table for users"
  value       = module.user_management.users_table
}

output "user_management_users_table_arn" {
  description = "The ARN of the DynamoDB table for users"
  value       = module.user_management.users_table_arn
}

output "user_management_users_table_stream_arn" {
  description = "The stream ARN of the DynamoDB table for users"
  value       = module.user_management.users_table_stream_arn
}
