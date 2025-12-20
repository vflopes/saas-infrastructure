resource "aws_route53_zone" "root" {
  name = local.root_domain
}

resource "aws_route53_zone" "api" {
  name = "api.${local.root_domain}"
}

resource "aws_route53_record" "api_ns" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "api.${local.root_domain}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.api.name_servers
}
