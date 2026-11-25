# Certificado SSL/TLS publico gerenciado no AWS Certificate Manager (ACM)
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
