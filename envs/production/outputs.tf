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
