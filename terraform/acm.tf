# Certificado SSL/TLS público gerenciado no AWS Certificate Manager (ACM)
resource "aws_acm_certificate" "cert" {
  domain_name       = "barrosamorimd.work"
  validation_method = "DNS"

  # Opcional: adicionar www também
  subject_alternative_names = [
    "www.barrosamorimd.work"
  ]

  lifecycle {
    create_before_destroy = true
  }
}