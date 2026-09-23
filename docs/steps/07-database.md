# Etapa 07: Banco de Dados NoSQL com Amazon DynamoDB

## 1. Objetivo
- Provisionar uma tabela NoSQL gerenciada no **Amazon DynamoDB** para persistir a contagem de acessos ao currículo.
- Inicializar o registro base do contador utilizando Infraestrutura como Código (Terraform).
- Garantir arquitetura Serverless com custo zero em repouso através do modelo de cobrança sob demanda (*On-Demand / Pay-per-request*).
- Exportar os identificadores e ARNs da tabela para futura integração com funções AWS Lambda e políticas IAM de menor privilégio.

---

## 2. Decisões de Arquitetura e Modelagem

1. **Escolha do DynamoDB (NoSQL Key-Value):**
   - Para um contador atômico de visitas, um banco de dados relacional (RDS) adicionaria complexidade de gerenciamento, necessidade de VPC e custos fixos contínuos.
   - O DynamoDB oferece operações nativas de incremento atômico (`ADD`), latência em milissegundos de um dígito e integração nativa com o ecossistema Serverless da AWS.

2. **Modo de Faturamento (`PAY_PER_REQUEST`):**
   - Optou-se pelo modo On-Demand. Não há necessidade de dimensionar capacidade provisionada (RCU/WCU), garantindo que o custo seja estritamente zero quando não houver requisições, perfeitamente elegível ao Free Tier da AWS.

3. **Chave Primária Simples:**
   - **Partition Key (`hash_key`):** `id` (Tipo String).
   - O item fixo responsável por armazenar a métrica global do site utiliza o identificador `"id": "visitors"`.

4. **Ciclo de Vida do Registro Inicial (`lifecycle.ignore_changes`):**
   - Para evitar que execuções subsequentes do `terraform apply` sobreponham o contador atualizado pela API resetando-o para zero, aplicou-se a diretiva `lifecycle { ignore_changes = [item] }` no recurso `aws_dynamodb_table_item`.

---

## 3. Implementação com Terraform

### 3.1. Provisionamento da Tabela e Item Inicial (`terraform/dynamodb.tf`)

```hcl
# 1. Definicao da Tabela no DynamoDB
resource "aws_dynamodb_table" "visitor_counter" {
  name         = "cloud-resume-visitor-counter"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "CloudResumeChallenge"
  }
}

# 2. Registro Inicial do Contador
resource "aws_dynamodb_table_item" "initial_record" {
  table_name = aws_dynamodb_table.visitor_counter.name
  hash_key   = aws_dynamodb_table.visitor_counter.hash_key

  item = jsonencode({
    "id" : { "S" : "visitors" },
    "count" : { "N" : "0" }
  })

  lifecycle {
    ignore_changes = [item]
  }
}
```

---

### 3.2. Exposição dos Outputs (`terraform/outputs.tf`)

Configuração das saídas de dados para reutilização no backend:

```hcl
output "dynamodb_table_name" {
  description = "Nome da tabela do DynamoDB para o contador de visitantes"
  value       = aws_dynamodb_table.visitor_counter.name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela do DynamoDB (utilizado nas permissoes IAM da Lambda)"
  value       = aws_dynamodb_table.visitor_counter.arn
}
```

---

## 4. Execução e Deploy

Execução do fluxo padrão de validação e aplicação da infraestrutura:

```bash
terraform fmt
terraform plan
terraform apply
```

*Saída resumida do deploy:*
```text
aws_dynamodb_table.visitor_counter: Creating...
aws_dynamodb_table.visitor_counter: Creation complete after 9s [id=cloud-resume-visitor-counter]
aws_dynamodb_table_item.initial_record: Creating...
aws_dynamodb_table_item.initial_record: Creation complete after 0s [id=cloud-resume-visitor-counter|id|visitors]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
dynamodb_table_arn = "arn:aws:dynamodb:us-east-1:696537703431:table/cloud-resume-visitor-counter"
dynamodb_table_name = "cloud-resume-visitor-counter"
```

---

## 5. Testes e Validação Técnica

### Consulta Direta via AWS CLI
Validação da persistência e do formato do item criado através do terminal:

```bash
aws dynamodb get-item \
  --table-name cloud-resume-visitor-counter \
  --key '{"id": {"S": "visitors"}}'
```

*Retorno obtido:*
```json
{
    "Item": {
        "id": {
            "S": "visitors"
        },
        "count": {
            "N": "0"
        }
    }
}
```

*Resultado:* Tabela provisionada e registro inicial `visitors` confirmado com valor numérico `0`.