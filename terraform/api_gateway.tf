# 1. API Gateway HTTP API (v2) com CORS habilitado
resource "aws_apigatewayv2_api" "visitor_counter_api" {
  name          = "cloud-resume-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 86400
  }

  tags = {
    Project = "CloudResumeChallenge"
  }
}

# 2. Integracao HTTP API com a Lambda (Payload 2.0 compativel)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.visitor_counter_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.visitor_counter.arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# 3. Rota padrao (captura todas as rotas e entrega para a funcao)
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.visitor_counter_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 4. Stage com auto-deploy imediato
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.visitor_counter_api.id
  name        = "$default"
  auto_deploy = true
}

# 5. Permissao para o API Gateway invocar a Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_counter_api.execution_arn}/*/*"
}