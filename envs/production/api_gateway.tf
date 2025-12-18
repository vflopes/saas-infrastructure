resource "aws_apigatewayv2_api" "backend_api" {
  name          = "backend-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "v1_stage" {
  api_id = aws_apigatewayv2_api.backend_api.id
  name   = "v1"
}