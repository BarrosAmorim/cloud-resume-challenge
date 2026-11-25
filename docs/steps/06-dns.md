# Etapa 06: Configuração de DNS e Domínio Personalizado

## 1. Objetivo
- Associar um domínio personalizado (`rpi5.stream` e `www.rpi5.stream`) à distribuição do Amazon CloudFront.
- Solicitar e validar um certificado SSL/TLS público e gratuito através do AWS Certificate Manager (ACM).
- Configurar os apontamentos de tráfego e validação no painel DNS da Cloudflare mantendo as melhores práticas de renovação contínua e entrega segura.
- Gerir a infraestrutura de certificados e a associação à CDN via Terraform (IaC).

---

## 2. Decisões de Arquitetura e Engenharia

1. **Localização do Certificado ACM (`us-east-1`):**
   - O Amazon CloudFront exige obrigatoriamente que qualquer certificado SSL/TLS associado a uma distribuição esteja provisionado na região `us-east-1` (Norte da Virgínia). Como o fornecedor principal do Terraform já opera nesta região, o certificado foi emitido directamente no mesmo módulo.

2. **Validação por DNS vs Validação por E-mail:**
   - Foi adoptado o método `DNS`, que permite automatizar a validação e, crucialmente, manter a renovação automática gerida pela AWS todos os anos, desde que os registos CNAME permaneçam activos no servidor de nomes.

3. **Modo DNS Only na Cloudflare:**
   - Os registos de validação do ACM e de tráfego da CDN foram configurados no modo **DNS Only** (nuvem cinzenta), permitindo que a AWS valide a autoridade sobre o domínio e que a terminação TLS/SSL ocorra directamente nos servidores de borda (*Edge Locations*) da AWS.

---

## 3. Implementação com Terraform

### 3.1. Solicitação do Certificado (`terraform/acm.tf`)
Criação do recurso para solicitar o certificado cobrindo o domínio raiz e o subdomínio `www`:

```hcl
# Certificado SSL/TLS público gerenciado no AWS Certificate Manager (ACM)
resource "aws_acm_certificate" "cert" {
  domain_name       = "rpi5.stream"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.rpi5.stream"
  ]

  lifecycle {
    create_before_destroy = true
  }
}
```

---

### 3.2. Exposição dos Registos de Validação (`terraform/outputs.tf`)
Exportação dos registos CNAME gerados pelo ACM para consulta directa no terminal:

```hcl
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
```

---

### 3.3. Atualização da Distribuição (`terraform/cloudfront.tf`)
Configuração dos nomes alternativos (`aliases`) e da referência do certificado no bloco `viewer_certificate`:

```hcl
# 1. Origin Access Control (OAC) para autenticação segura no S3
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac-${aws_s3_bucket.resume_bucket.id}"
  description                       = "OAC para acesso seguro ao bucket S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. Distribuição CloudFront (CDN + HTTPS + Custom Domain)
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "Distribuicao CDN para o Cloud Resume Challenge"
  price_class         = "PriceClass_100"

  # Nomes de domínio personalizados
  aliases = [
    "rpi5.stream",
    "www.rpi5.stream"
  ]

  origin {
    domain_name              = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Certificado SSL personalizado do ACM
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# 3. Bucket Policy permitindo leitura SOMENTE pelo CloudFront via OAC
resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = aws_s3_bucket.resume_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.resume_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}
```

---

## 4. Configuração dos Registos DNS na Cloudflare

A tabela DNS na Cloudflare foi configurada com 4 registos CNAME dedicados (todos em modo **DNS Only**):

| Tipo | Nome | Conteúdo / Destino | Finalidade |
| :--- | :--- | :--- | :--- |
| **CNAME** | `@` | `d26is0r520jrs6.cloudfront.net` | Roteamento de tráfego do domínio raiz |
| **CNAME** | `www` | `d26is0r520jrs6.cloudfront.net` | Roteamento de tráfego do subdomínio www |
| **CNAME** | `_cdb0f924bdf1049ec851f7dff18281cb` | `_4f2368697f78c320045ad50b4fd356ee.wzccmgtwzk.acm-validations.aws.` | Validação e renovação contínua da raiz |
| **CNAME** | `_ddbd359b7c8b918b9955ed2f05820e7e.www` | `_5e001bbf4ace74dae24bf89267e5702d.wzccmgtwzk.acm-validations.aws.` | Validação e renovação contínua do subdomínio www |

---

## 5. Validação e Testes Práticos

### 5.1. Consulta de Resolução DNS
Execução do `dig` para validar a resolução Anycast do domínio raiz:

```bash
dig +short rpi5.stream
```

*Retorno obtido:*
```text
52.85.78.7
52.85.78.67
52.85.78.119
52.85.78.89
```

---

### 5.2. Teste de Acesso HTTPS nos Domínios
Execução de chamadas aos cabeçalhos HTTP nos dois domínios:

```bash
curl -I [https://rpi5.stream](https://rpi5.stream)
curl -I [https://www.rpi5.stream](https://www.rpi5.stream)
```

*Retorno obtido:*
```text
HTTP/2 200 
content-type: text/html
server: AmazonS3
x-cache: Hit from cloudfront
via: 1.1 b1da973ba67f53dd7b3b0c402185a7f6.cloudfront.net (CloudFront)

HTTP/2 200 
content-type: text/html
server: AmazonS3
x-cache: Hit from cloudfront
via: 1.1 d5395586b525dd4393f668eb60b2e0fc.cloudfront.net (CloudFront)
```

*Análise:* A entrega do conteúdo estático ocorre com sucesso sob protocolo HTTP/2 e com estado de cache `Hit from cloudfront`, garantindo baixa latência e total segurança de tráfego.