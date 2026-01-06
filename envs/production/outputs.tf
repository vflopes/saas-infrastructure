output "github_oid_role_arn" {
  description = "The ARN of the IAM role for GitHub OIDC"
  value       = aws_iam_role.github_oidc.arn
}

output "root_domain" {
  description = "The root domain for the production environment"
  value       = local.root_domain
}

output "root_domain_dns_server_names" {
  description = "The DNS server names for the root domain's Route 53 hosted zone"
  value       = aws_route53_zone.root.name_servers
}

output "root_domain_certificate_arn" {
  description = "The ARN of the ACM certificate for the root domain"
  value       = aws_acm_certificate_validation.root_domain.certificate_arn
}

output "ses_root_domain_identity_arn" {
  description = "The ARN of the SES domain identity for the root domain"
  value       = aws_ses_domain_identity_verification.root_domain_verification.arn
}

output "api_gateway_id" {
  description = "The ID of the API Gateway for the production environment"
  value       = aws_apigatewayv2_api.saas_api.id
}
