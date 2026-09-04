# Etapa 11 — Infrastructure as Code (AWS SAM)

## Objetivo

Transformar a infraestrutura do backend do Cloud Resume Challenge em **Infrastructure as Code (IaC)** utilizando **AWS SAM (Serverless Application Model)** e **AWS CloudFormation**.

Até esta etapa, os recursos do backend haviam sido criados e configurados manualmente através do AWS Management Console. A infraestrutura passou a ser descrita em `template.yaml`, a partir do qual o AWS SAM gera e provisiona os recursos via CloudFormation.

## Por que Infrastructure as Code?

Em vez de configurar manualmente cada recurso pelo console, a infraestrutura passa a ser descrita em código:

```
template.yaml → SAM CLI → CloudFormation → AWS
```

Isso torna a infraestrutura reproduzível, versionável, automatizável e mais fácil de documentar, modificar e recriar em outro ambiente.

## Por que AWS SAM?

O projeto utiliza principalmente serviços serverless (Lambda, DynamoDB, API Gateway, IAM). O SAM é uma extensão do CloudFormation voltada para aplicações serverless, permitindo descrever recursos como `AWS::Serverless::Function` e `AWS::Serverless::HttpApi` em um template YAML.

## Instalação do AWS SAM CLI

Versão utilizada: `AWS SAM CLI 1.165.0`. A configuração da AWS foi validada com `aws configure list` e a identidade da conta com `aws sts get-caller-identity`.

## Estrutura do projeto

```
cloud-resume-challenge/
│
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
│
├── backend/
│   ├── lambda_function.py
│   └── test_lambda_function.py
│
├── template.yaml
├── .gitignore
└── README.md
```

## Template SAM

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31
Description: >
  Infraestrutura do Cloud Resume Challenge
  utilizando AWS SAM.

Resources:
  CloudResumeVisitorCount:
    Type: AWS::DynamoDB::Table
    DeletionPolicy: Retain
    UpdateReplacePolicy: Retain
    Properties:
      TableName: CloudResumeVisitorCountSAM
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: id
          AttributeType: S
      KeySchema:
        - AttributeName: id
          KeyType: HASH
      Tags:
        - Key: Project
          Value: CloudResumeChallenge

  CloudResumeCounter:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: cloud-resume-counter-sam
      Runtime: python3.14
      Handler: lambda_function.lambda_handler
      CodeUri: backend/
      Timeout: 3
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref CloudResumeVisitorCount
      Events:
        CountApi:
          Type: HttpApi
          Properties:
            ApiId: !Ref CloudResumeApi
            Path: /count
            Method: GET

  CloudResumeApi:
    Type: AWS::Serverless::HttpApi
    Properties:
      Name: CloudResumeAPI-SAM
      StageName: $default
      CorsConfiguration:
        AllowOrigins:
          - https://barrosamorimd.work
        AllowMethods:
          - GET
```

## Recursos definidos no template

- **DynamoDB** — cria a tabela `CloudResumeVisitorCountSAM`, modo `PAY_PER_REQUEST`, chave primária `id` (String).
- **Lambda** — função `cloud-resume-counter-sam`, runtime Python 3.14, handler `lambda_function.lambda_handler`, timeout de 3 segundos.
- **API Gateway** — `CloudResumeAPI-SAM`, stage `$default`, com a rota `GET /count`.

## Permissões IAM

Em vez de criar manualmente uma IAM Role e políticas pelo console, o SAM utiliza:

```yaml
Policies:
  - DynamoDBCrudPolicy:
      TableName: !Ref CloudResumeVisitorCount
```

O `!Ref` faz referência ao recurso DynamoDB definido no próprio template, vinculando a permissão à tabela criada pela stack. O SAM também cria automaticamente a IAM Role de execução da Lambda.

## Integração entre API Gateway e Lambda

Definida diretamente no template via `Events`, o SAM configura automaticamente a rota, a integração e a permissão necessária para o API Gateway invocar a Lambda.

## CORS

```yaml
CorsConfiguration:
  AllowOrigins:
    - https://barrosamorimd.work
  AllowMethods:
    - GET
```

## Validação, build e deploy

```
sam validate --lint   → template.yaml is a valid SAM Template
sam build              → Build Succeeded (.aws-sam/build)
sam deploy --guided    → stack cloud-resume-challenge, região us-east-1
```

O `.aws-sam/` foi adicionado ao `.gitignore`. Após o deploy inicial, foi criado o `samconfig.toml`, armazenando as configurações para deployments subsequentes.

## CloudFormation

O AWS SAM utiliza o CloudFormation para provisionamento. Status final da stack: `UPDATE_COMPLETE`.

Recursos criados automaticamente:

```
CloudResumeVisitorCount   → DynamoDB (CloudResumeVisitorCountSAM)
CloudResumeCounter        → Lambda (cloud-resume-counter-sam)
CloudResumeCounterRole    → IAM Role
CloudResumeApi            → API Gateway (CloudResumeAPI-SAM)
CloudResumeCounterCountApiPermission → Permissão API Gateway → Lambda
CloudResumeApiApiGatewayDefaultStage → Stage $default
```

## Testes pós-deploy

Teste direto da Lambda via AWS CLI:

```
aws lambda invoke --function-name cloud-resume-counter-sam --payload "{}" response.json
```

Execuções consecutivas retornaram `count: 1` e depois `count: 2`.

Endpoint da API obtido via `sam list endpoints --stack-name cloud-resume-challenge`:

```
https://7qai572l60.execute-api.us-east-1.amazonaws.com/$default/count
```

Teste com `curl` confirmou `{"count": 3}`, validando a integração completa.

## Infraestrutura antiga e nova

Durante a implementação, a infraestrutura original criada manualmente pelo console foi mantida em paralelo à nova infraestrutura gerenciada pelo SAM (`CloudResumeVisitorCountSAM`, `cloud-resume-counter-sam`, `CloudResumeAPI-SAM`), permitindo testar sem interromper o site em produção.

## Resultado

A infraestrutura do backend passou a ser definida como código através do `template.yaml`, cobrindo DynamoDB, Lambda, IAM, API Gateway, integrações, permissões e CORS. A infraestrutura foi validada, construída e implantada com `sam validate`, `sam build` e `sam deploy`, e testada com sucesso via `GET /count`.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
