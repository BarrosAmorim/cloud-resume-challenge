# 1. Bucket S3 para armazenar os arquivos estáticos do site
resource "aws_s3_bucket" "resume_bucket" {
  bucket = "cloud-resume-challenge-rafael"
}

# 2. Bloqueio rigoroso de acesso público (Security by Default)
resource "aws_s3_bucket_public_access_block" "resume_bucket_pab" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Upload do index.html com Content-Type explícito
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "index.html"
  source       = "${path.module}/../frontend/index.html"
  etag         = filemd5("${path.module}/../frontend/index.html")
  content_type = "text/html"
}

# 4. Upload do style.css com Content-Type explícito
resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "style.css"
  source       = "${path.module}/../frontend/style.css"
  etag         = filemd5("${path.module}/../frontend/style.css")
  content_type = "text/css"
}