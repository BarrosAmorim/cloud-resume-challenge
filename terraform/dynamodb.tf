# 1. Definição da Tabela no DynamoDB
resource "aws_dynamodb_table" "visitor_counter" {
  name         = "cloud-resume-visitor-counter"
  billing_mode = "PAY_PER_REQUEST" # On-Demand (sem custo fixo, ideal para o Free Tier)
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S" # String
  }

  tags = {
    Project = "CloudResumeChallenge"
  }
}

# 2. Registo Inicial do Contador (fora da tabela)
resource "aws_dynamodb_table_item" "initial_record" {
  table_name = aws_dynamodb_table.visitor_counter.name
  hash_key   = aws_dynamodb_table.visitor_counter.hash_key

  item = jsonencode({
    "id" : { "S" : "visitors" },
    "count" : { "N" : "0" }
  })

  lifecycle {
    ignore_changes = [item] # Evita que o Terraform resete o contador nas próximas execuções
  }
}