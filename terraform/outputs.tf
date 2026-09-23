# caçar a URL do CloudFront manualmente na AWS, crie o arquivo outputs.tf. Ele vai imprimir no terminal a URL HTTPS pronta assim que o deploy terminar:
output "cloudfront_url" {
  description = "URL publica segura (HTTPS) do site no CloudFront"
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}
# imprimir o nome exato do bucket S3 no terminal assim que o comando terraform apply for concluído.
output "s3_bucket_name" {
  description = "Nome do bucket S3 provisionado"
  value       = aws_s3_bucket.resume_bucket.id
}

# Informações de validação DNS para cadastrar na Cloudflare
output "acm_validation_records" {
  description = "Registros CNAME necessarios para validar o certificado na Cloudflare"
  value = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}

# Informações do banco e da tabela do dynamo
output "dynamodb_table_name" {
  description = "Nome da tabela do DynamoDB para o contador de visitantes"
  value       = aws_dynamodb_table.visitor_counter.name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela do DynamoDB (utilizado nas permissoes IAM da Lambda)"
  value       = aws_dynamodb_table.visitor_counter.arn
}

# Exportar a URL da API
output "visitor_counter_api_url" {
  description = "Endpoint HTTPS publico do API Gateway para o contador de visitas"
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}