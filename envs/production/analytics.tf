module "analytics" {
  source = "./analytics"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
}

output "analytics_queue_url" {
  description = "The URL of the analytics SQS queue"
  value       = module.analytics.analytics_queue_url
}

output "analytics_queue_arn" {
  description = "The ARN of the analytics SQS queue"
  value       = module.analytics.analytics_queue_arn
}
