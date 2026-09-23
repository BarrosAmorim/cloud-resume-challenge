# Etapa 10: Backend Serverless em Python com AWS Lambda

## 1. Objetivo
- Desenvolver a lógica de negócio do contador de acessos utilizando Python 3.12 e o SDK oficial da AWS (boto3).
- Implementar operações de incremento atômico diretamente no Amazon DynamoDB para prevenir condições de corrida (race conditions).
- Provisionar e gerenciar toda a infraestrutura computacional e permissões de segurança de menor privilégio via Terraform (terraform/lambda.tf).
- Assegurar o envio automático de logs de execução para auditoria no Amazon CloudWatch Logs.

---

## 2. Decisões de Arquitetura e Engenharia

1. Incremento Atômico com UpdateItem:
   - Em vez de realizar uma leitura (GetItem), somar em memória local e depois salvar (PutItem) — o que causaria inconsistência em acessos simultâneos —, utilizou-se a expressão de atualização nativa do DynamoDB:
     UpdateExpression="ADD #count :incr"
   - O DynamoDB garante a consistência atômica no próprio motor do banco, retornando o valor atualizado em milissegundos através do parâmetro ReturnValues="UPDATED_NEW".

2. Gestão de Dependências e Runtime:
   - Runtime: python3.12.
   - Como o SDK boto3 já vem pré-instalado no ambiente de execução gerenciado da AWS Lambda, não há necessidade de empacotar camadas (Lambda Layers) externas, mantendo o arquivo .zip extremamente leve.

3. Princípio do Menor Privilégio (IAM Least Privilege):
   - A Role de execução (aws_iam_role.lambda_exec) foi configurada com escopo estrito:
     - Escrita básica de logs através da política gerenciada AWSLambdaBasicExecutionRole.
     - Permissão no DynamoDB restrita exclusivamente às ações dynamodb:UpdateItem e dynamodb:GetItem, apontando apenas para o ARN exato da tabela.

4. Desacoplamento via Variáveis de Ambiente:
   - O nome da tabela é injetado dinamicamente via variável de ambiente (TABLE_NAME = aws_dynamodb_table.visitor_counter.name), permitindo reutilização do código em múltiplos ambientes sem hardcoding.

---

## 3. Código da Função (backend/lambda_function.py)

import json
import os
import boto3
from botocore.exceptions import ClientError

# Inicialização do cliente fora do handler para reaproveitamento de conexão (warm starts)
import json
import os
import boto3
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("TABLE_NAME", "cloud-resume-visitor-counter")
table = dynamodb.Table(table_name)

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    try:
        response = table.update_item(
            Key={"id": "visitors"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": 1},
            ReturnValues="UPDATED_NEW"
        )

        visitor_count = response["Attributes"]["count"]

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
            },
            "body": json.dumps({"count": visitor_count}, cls=DecimalEncoder)
        }

    except Exception as error:
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(error)})
        }
---

## 4. Implementação da Infraestrutura (terraform/lambda.tf)

# 1. Empacotamento automático do código Python em arquivo .zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/lambda_function.py"
  output_path = "${path.module}/../backend/lambda_function.zip"
}

# 2. IAM Role para execução da Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "cloud-resume-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Permissões CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 4. Política de Menor Privilégio para DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "cloud-resume-lambda-dynamodb-policy"
  description = "Permite a Lambda atualizar e ler o contador no DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.visitor_counter.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# 5. Função AWS Lambda
resource "aws_lambda_function" "visitor_counter" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "cloud-resume-visitor-counter"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_counter.name
    }
  }

  tags = {
    Project = "CloudResumeChallenge"
  }
}

---

## 5. Validação Técnica

### Verificação dos Registros no Amazon CloudWatch Logs
Após o acionamento da função via API Gateway, a criação do grupo de logs e a execução sem erros foram confirmadas via terminal:

aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/cloud-resume-visitor-counter"

Resultado: Função implantada via Terraform com empacotamento automático baseado em hash SHA256, permissões atreladas apenas à tabela necessária e incremento atômico validado com sucesso.