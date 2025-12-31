resource "aws_ses_domain_identity" "root_domain" {
  domain = local.root_domain
}

data "aws_iam_policy_document" "root_domain_identity_policy" {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = [aws_ses_domain_identity.root_domain.arn]

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

  }
}

resource "aws_ses_identity_policy" "root_domain_identity_policy" {
  identity = aws_ses_domain_identity.root_domain.arn
  name     = "identity-policy"
  policy   = data.aws_iam_policy_document.root_domain_identity_policy.json
}

resource "aws_route53_record" "root_domain_ses_verification" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "_amazonses.${local.root_domain}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_ses_domain_identity.root_domain.verification_token]
}

resource "aws_ses_domain_identity_verification" "root_domain_verification" {
  domain = aws_ses_domain_identity.root_domain.domain

  depends_on = [
    aws_route53_record.root_domain_ses_verification
  ]
}

resource "aws_ses_domain_dkim" "root_domain_dkim" {
  domain = aws_ses_domain_identity.root_domain.domain
}

resource "aws_route53_record" "root_domain_dkim" {
  count = 3

  zone_id = aws_route53_zone.root.zone_id
  name    = "${element(aws_ses_domain_dkim.root_domain_dkim.dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = "60"
  records = ["${element(aws_ses_domain_dkim.root_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_s3_bucket" "root_domain_emails_bucket" {
  bucket_prefix = "root-domain-emails-"
}

data "aws_iam_policy_document" "root_domain_emails_bucket_policy" {
  statement {
    sid     = "AllowSESPuts"
    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    resources = [
      "${aws_s3_bucket.root_domain_emails_bucket.arn}/*",
    ]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:ses:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:receipt-rule-set/${aws_ses_receipt_rule_set.root_domain_primary.rule_set_name}:receipt-rule/*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_ses_domain_mail_from" "root_domain_mail_from" {
  domain           = aws_ses_domain_identity.root_domain.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.root_domain.domain}"
}

resource "aws_route53_record" "root_domain_mail_from_mx" {
  zone_id = aws_route53_zone.root.id
  name    = aws_ses_domain_mail_from.root_domain_mail_from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.region}.amazonses.com"]
}

resource "aws_route53_record" "root_domain_mail_from_txt" {
  zone_id = aws_route53_zone.root.id
  name    = aws_ses_domain_mail_from.root_domain_mail_from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_s3_bucket_policy" "root_domain_store_policy" {
  bucket = aws_s3_bucket.root_domain_emails_bucket.id
  policy = data.aws_iam_policy_document.root_domain_emails_bucket_policy.json
}

resource "aws_ses_receipt_rule_set" "root_domain_primary" {
  rule_set_name = "primary-rules"
}

resource "aws_ses_receipt_rule" "root_domain_store" {
  name          = "store-root-domain-emails"
  rule_set_name = aws_ses_receipt_rule_set.root_domain_primary.rule_set_name
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name       = aws_s3_bucket.root_domain_emails_bucket.id
    object_key_prefix = "incoming"
    position          = 1
  }

  depends_on = [
    aws_s3_bucket_policy.root_domain_store_policy
  ]
}
