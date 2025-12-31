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

resource "aws_route53_record" "root_domain_txt" {
  zone_id = aws_route53_zone.root.zone_id
  name    = local.root_domain
  type    = "TXT"
  ttl     = "30"
  records = [
    var.google_site_verification_value,
    "v=spf1 include:_spf.google.com ~all"
  ]
}

resource "aws_route53_record" "gmail_mx" {
  zone_id = aws_route53_zone.root.zone_id
  name    = local.root_domain
  type    = "MX"
  ttl     = "30"
  records = [
    "1 SMTP.GOOGLE.COM.",
  ]
}

# https://dkimvalidator.com/results
resource "aws_route53_record" "gmail_dkim" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "google._domainkey.${local.root_domain}"
  type    = "TXT"
  ttl     = "30"
  records = [var.gmail_dkim_value]
}
resource "aws_acm_certificate" "root_domain" {
  provider                  = aws.aws_us_east_1
  domain_name               = local.root_domain # Replace with your full domain
  validation_method         = "DNS"
  subject_alternative_names = ["*.${local.root_domain}"] # Optional: add apex domain or wildcards

  lifecycle {
    create_before_destroy = true # Ensures seamless updates
  }
}

resource "aws_acm_certificate_validation" "root_domain" {
  certificate_arn         = aws_acm_certificate.root_domain.arn
  validation_record_fqdns = [for record in aws_route53_record.root_domain : record.fqdn]
}


resource "aws_route53_record" "root_domain" {
  for_each = {
    for dvo in aws_acm_certificate.root_domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.root.zone_id
}
