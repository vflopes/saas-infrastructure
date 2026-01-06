resource "aws_apigatewayv2_api" "saas_api" {
  name                         = "saas-api"
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = true
  route_selection_expression   = "$request.method $request.path"
  cors_configuration {
    allow_origins = [
      "https://saas.vflopes.com",
      "http://localhost:3000"
    ]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = [
      "Authorization",
      "Content-Type",
      "X-Requested-With"
    ]
    expose_headers = [
      "X-Request-Id",
      "X-Rate-Limit-Remaining"
    ]
    allow_credentials = true
    max_age           = 3600
  }
}

resource "aws_apigatewayv2_domain_name" "saas_api" {
  domain_name = "api.${local.root_domain}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.root_domain.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "saas_api" {
  name    = aws_apigatewayv2_domain_name.saas_api.domain_name
  type    = "A"
  zone_id = aws_route53_zone.root.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.saas_api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.saas_api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_stage" "saas_api_v1" {
  api_id      = aws_apigatewayv2_api.saas_api.id
  name        = "v1"
  auto_deploy = true

  route_settings {
    route_key = "$default"
  }
}
