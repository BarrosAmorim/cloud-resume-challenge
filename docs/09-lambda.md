# Etapa 9 — Python (AWS Lambda)

## Objetivo

Criar uma função AWS Lambda utilizando Python para acessar o DynamoDB, incrementar a quantidade de visitantes e retornar o novo valor do contador. Também foi configurada a permissão IAM necessária para que a Lambda pudesse acessar e atualizar o DynamoDB.

## Serviços utilizados

- AWS Lambda
- AWS IAM
- Amazon DynamoDB
- Amazon CloudWatch Logs

## 1. Criar a função Lambda

Acessei o serviço **AWS Lambda** pelo console da AWS e configurei:

- Nome da função: `cloud-resume-counter`
- Runtime: `Python 3.14`
- Região: `us-east-1`

A função foi criada com uma role de execução própria: `cloud-resume-counter-role-lo5xeumx`. A AWS também adicionou automaticamente a permissão básica necessária para envio de logs ao CloudWatch.

## 2. Configurar a permissão IAM para o DynamoDB

A função Lambda precisa acessar a tabela `CloudResumeVisitorCount`. Foi criada uma política inline específica: `CloudResumeDynamoDBAccess`.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["dynamodb:GetItem", "dynamodb:UpdateItem"],
      "Resource": "arn:aws:dynamodb:us-east-1:<ACCOUNT_ID>:table/CloudResumeVisitorCount"
    }
  ]
}
```

A política permite `dynamodb:GetItem` (consultar) e `dynamodb:UpdateItem` (atualizar/incrementar), limitada especificamente à tabela `CloudResumeVisitorCount`, seguindo o princípio do menor privilégio.

## 3. Código Python

```python
import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("CloudResumeVisitorCount")

def lambda_handler(event, context):

    response = table.update_item(
        Key={
            "id": "visitor-count"
        },
        UpdateExpression="ADD #count :inc",
        ExpressionAttributeNames={
            "#count": "count"
        },
        ExpressionAttributeValues={
            ":inc": 1
        },
        ReturnValues="UPDATED_NEW"
    )

    count = response["Attributes"]["count"]

    return {
        "statusCode": 200,
        "body": json.dumps({
            "count": int(count)
        })
    }
```

A função:

1. Importa `boto3`.
2. Cria uma conexão com o DynamoDB.
3. Seleciona a tabela `CloudResumeVisitorCount`.
4. Localiza o item cujo `id` é `visitor-count`.
5. Incrementa o campo `count` em `1` (`ADD #count :inc` com `:inc = 1`).
6. Obtém o novo valor (`ReturnValues="UPDATED_NEW"`).
7. Retorna o novo contador com `statusCode 200`.

## 4. Deploy

Após inserir o código, o deploy foi feito diretamente no console da AWS Lambda, com confirmação de sucesso.

## 5. Evento de teste

- Tipo de invocação: **Síncrona**
- Nome do evento: `test-counter`
- JSON do evento: `{}`

## 6. Execução do teste

Resultado da primeira execução após implementar o incremento:

```json
{
  "statusCode": 200,
  "body": "{\"count\": 1}"
}
```

Isso confirmou que a Lambda conseguiu executar corretamente, acessar o DynamoDB, incrementar o contador e retornar o resultado. Posteriormente, o funcionamento também foi validado através do site publicado (`Visitantes: 50` → `Visitantes: 51`).

## Arquitetura da etapa

```
AWS Lambda
    │
    │ boto3
    ▼
Amazon DynamoDB
    │
    ▼
CloudResumeVisitorCount
    │
    └── visitor-count
            │
            └── count + 1
```

## Resultado

A função Lambda foi criada e configurada com Python 3.14, utilizando `boto3` para acessar o DynamoDB e incrementar o contador de visitantes a cada execução, retornando o novo valor através da API.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
