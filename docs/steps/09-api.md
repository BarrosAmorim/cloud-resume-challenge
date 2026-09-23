# Etapa 08: API com Amazon API Gateway (HTTP API v2)

## 1. Objetivo
- Expor um ponto de extremidade público HTTPS para receber as requisições de contagem de visitas vindas do frontend.
- Integrar a camada web à função AWS Lambda de forma desacoplada via proxy HTTP.
- Implementar configurações globais de Cross-Origin Resource Sharing (CORS).
- Resolver impedimentos de segurança corporativa (bloqueio por Service Control Policies em Function URLs diretas).
- Declarar e gerenciar 100% dos recursos de rede via Terraform (`terraform/api_gateway.tf`).

---

## 2. Decisões de Arquitetura e Engenharia

1. **Escolha da HTTP API (API Gateway v2) vs REST API:**
   - **Custo e Desempenho:** A HTTP API v2 oferece latência significativamente menor (~10ms a menos de overhead) e custa cerca de 70% menos que as REST APIs tradicionais.
   - **Simplicidade de Configuração:** Suporte nativo e simplificado a CORS e payload format version 2.0 integrado diretamente à Lambda.

2. **Resolução de Erro de Governança (SCP - 403 Forbidden):**
   - Ao tentar utilizar *Lambda Function URLs* diretamente com tipo de autenticação `NONE`, a requisição retornava erro `403 Forbidden`.
   - **Causa Raiz:** A conta AWS faz parte de uma AWS Organization com Service Control Policies (SCPs) que restringem a criação de Function URLs públicas diretas sem autenticação IAM.
   - **Solução Arquitetural:** Implementação do Amazon API Gateway à frente da Lambda. O API Gateway atua como fachada pública autorizada e estabelece uma comunicação interna segura via `apigateway.amazonaws.com` com a função Lambda, contornando a restrição sem violar as políticas de segurança da organização.

3. **Política de CORS (Cross-Origin Resource Sharing):**
   - Para permitir que o website estático (hospedado via CloudFront/S3) faça chamadas AJAX/fetch para o backend sem bloqueios de segurança do navegador, foram liberadas as origens com os métodos `GET`, `POST` e `OPTIONS`.

---

## 3. Implementação com Terraform (`terraform/api_gateway.tf`)

```hcl
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

# 3. Rota padrao (captura requisicoes e entrega para a funcao)
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

# 5. Permissao explicita para o API Gateway invocar a Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_counter_api.execution_arn}/*/*"
}

---

4. Exposição de Saída (terraform/outputs.tf)

output "visitor_counter_api_url" {
  description = "Endpoint publico gerado pelo API Gateway HTTP API"
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}

5. Testes e Validação Técnica
Chamada Externa via cURL
Disparo de teste simulando a requisição do navegador contra a URL exposta no output do Terraform:

curl -i -X POST $(terraform output -raw visitor_counter_api_url) \
  -H "Content-Type: application/json"

Resposta obtida:

HTTP/2 200 
date: Wed, 23 Sep 2026 00:56:22 GMT
content-type: application/json
content-length: 12
apigw-requestid: EIKEfihPIAMEZ9w=

{"count": 3}

Resultado: API Gateway operacional, autenticação interna aceita pela Lambda e contador retornado com status 200 OK.