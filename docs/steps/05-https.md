# Etapa 05: HTTPS e CDN com Amazon CloudFront e OAC

## 1. Objetivo
- Configurar uma CDN (Content Delivery Network) global via Amazon CloudFront para entregar o site com baixa latência e alta disponibilidade.
- Impor tráfego estritamente seguro por meio de HTTPS (`redirect-to-https`).
- Proteger a origem no Amazon S3 mantendo o bucket totalmente privado, utilizando **Origin Access Control (OAC)** e **Bucket Policy** restritiva.
- Declarar e gerenciar toda a infraestrutura através do Terraform (IaC).

---

## 2. Decisões de Arquitetura e Engenharia

1. **Origin Access Control (OAC) vs OAI:**
   - Adotei o **OAC** (*Origin Access Control*), substituto moderno e recomendado pela AWS para o legado OAI (*Origin Access Identity*). O OAC suporta assinaturas SigV4 em todas as regiões, melhora a segurança e permite políticas granulares com a condição `AWS:SourceArn`.

2. **Otimização de Custos e Free Tier:**
   - Utilizei a classe de preço `PriceClass_100` (EUA, Canadá e Europa) no código declarativo, que garante latência excelente e opera 100% dentro do Free Tier perpétuo do CloudFront (1 TB de transferência e 10 milhões de requisições mensais gratuitas).

3. **Política de Cache Gerenciada:**
   - Associei a Cache Policy gerenciada da AWS `CachingOptimized` (`658327ea-f89d-4fab-a63d-7e88639e58f6`) para maximizar o cache hit na borda sem tráfego desnecessário para a origem S3.

---

## 3. Implementação com Terraform

### 3.1. Declaração dos Recursos (`terraform/cloudfront.tf`)
Criei o arquivo consolidando o OAC, a distribuição do CloudFront e a política de acesso ao bucket:

```hcl
# 1. Origin Access Control (OAC) para autenticação segura no S3
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac-${aws_s3_bucket.resume_bucket.id}"
  description                       = "OAC para acesso seguro ao bucket S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. Distribuição CloudFront (CDN + HTTPS)
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "Distribuicao CDN para o Cloud Resume Challenge"
  price_class         = "PriceClass_100"

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

    # Cache Policy padrão otimizada da AWS (CachingOptimized)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# 3. Bucket Policy permitindo leitura SOMENTE pelo CloudFront via OAC
resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = aws_s3_bucket.resume_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
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

### 3.2. Configuração de Saídas (`terraform/outputs.tf`)
Configurei o arquivo de outputs para extrair a URL final e o nome do bucket:

```hcl
output "cloudfront_url" {
  description = "URL publica segura (HTTPS) do site no CloudFront"
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "s3_bucket_name" {
  description = "Nome do bucket S3 provisionado"
  value       = aws_s3_bucket.resume_bucket.id
}
```

---

### 3.3. Formatação, Planejamento e Aplicação
Executei a formatação do código HCL, a validação do plano e apliquei as alterações:

```bash
cd ~/projects/cloud-resume-challenge/terraform
terraform fmt
terraform plan
terraform apply
```

*Saída de conclusão:*
```text
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

cloudfront_url = "[https://d3ju87qn7qf8sw.cloudfront.net](https://d3ju87qn7qf8sw.cloudfront.net)"
s3_bucket_name = "cloud-resume-challenge-rafael"
```

---

## 4. Testes Práticos e Validação de Segurança

Executei três verificações via linha de comando para validar a entrega, o redirecionamento HTTPS e o isolamento do bucket de origem:

### 4.1. Teste de Acesso Seguro (HTTPS)
Enviei uma requisição com o cabeçalho HTTP para a URL pública da CDN:

```bash
curl -I [https://d3ju87qn7qf8sw.cloudfront.net/](https://d3ju87qn7qf8sw.cloudfront.net/)
```

*Retorno obtido:*
```text
HTTP/2 200 
content-type: text/html
server: AmazonS3
x-cache: Miss from cloudfront
via: 1.1 351e9a960be9d54878a5327c677977a2.cloudfront.net (CloudFront)
```
*Análise:* O CloudFront atendeu à requisição com protocolo HTTP/2, autenticou no S3 via OAC e entregou o `index.html` com sucesso.

---

### 4.2. Teste de Redirecionamento Automático HTTP -> HTTPS
Testei o acesso usando explicitamente o protocolo inseguro `http://`:

```bash
curl -I [http://d3ju87qn7qf8sw.cloudfront.net/](http://d3ju87qn7qf8sw.cloudfront.net/)
```

*Retorno obtido:*
```text
HTTP/1.1 301 Moved Permanently
Server: CloudFront
Location: [https://d3ju87qn7qf8sw.cloudfront.net/](https://d3ju87qn7qf8sw.cloudfront.net/)
X-Cache: Redirect from cloudfront
```
*Análise:* A diretiva `viewer_protocol_policy = "redirect-to-https"` funcionou conforme o esperado, forçando o navegador a migrar para a conexão criptografada.

---

### 4.3. Teste de Isolamento do S3 (Acesso Direto Bloqueado)
Tentei consultar o arquivo diretamente pela URL do bucket S3:

```bash
curl -I [https://cloud-resume-challenge-rafael.s3.us-east-1.amazonaws.com/index.html](https://cloud-resume-challenge-rafael.s3.us-east-1.amazonaws.com/index.html)
```

*Retorno obtido:*
```text
HTTP/1.1 403 Forbidden
Content-Type: application/xml
Server: AmazonS3
```
*Análise:* A política do S3 (`aws_s3_bucket_policy`) bloqueia qualquer chamada não originada da distribuição CloudFront autorizada, garantindo que o bucket permaneça inacessível diretamente pela internet pública.

---

## 5. Diagrama de Fluxo e Segurança

```text
[ Usuário / Navegador ]
          |
          | 1. HTTP/HTTPS (d3ju87qn7qf8sw.cloudfront.net)
          v
[ Amazon CloudFront (CDN) ]
   ├── Redirect HTTP -> HTTPS (301)
   ├── Cache Policy: CachingOptimized
   └── Assinatura SigV4 via OAC (Origin Access Control)
          |
          | 2. Requisição autenticada (AWS:SourceArn da Distribuição)
          v
[ Amazon S3 (cloud-resume-challenge-rafael) ]
   ├── Block Public Access: [ATIVO]
   └── Bucket Policy: Allow somente para cloudfront.amazonaws.com
```