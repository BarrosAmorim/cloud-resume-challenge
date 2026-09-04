# Etapa 12 — CI/CD (Back-end)

## Objetivo

Automatizar os testes e a implantação do back-end utilizando **GitHub Actions**, **AWS SAM**, **AWS IAM** e **OIDC (OpenID Connect)**, evitando que alterações no código Python ou na infraestrutura precisem ser implantadas manualmente.

Fluxo desejado:

```
Alteração no código → git push → GitHub Actions → pytest → sam build
   → Autenticação OIDC → AWS IAM → sam deploy → CloudFormation
   → Lambda / API Gateway / DynamoDB
```

## Por que CI/CD?

Antes desta etapa, o processo era manual (alterar código → `pytest` → `sam build` → `sam deploy`). Com CI/CD, o GitHub passa a executar automaticamente o processo de validação e implantação a cada `git push`.

## Estrutura do repositório

```
cloud-resume-challenge/
│
├── backend/
│   ├── lambda_function.py
│   └── test_lambda_function.py
│
├── frontend/
│   ├── index.html
│   ├── script.js
│   └── style.css
│
├── .github/
│   └── workflows/
│       └── backend.yml
│
├── template.yaml
├── samconfig.toml
├── .gitignore
└── README.md
```

## Gatilhos do workflow

```yaml
paths:
  - "backend/**"
  - "template.yaml"
  - ".github/workflows/backend.yml"

push:
  branches: [main]
pull_request:
  branches: [main]
```

## Separação entre Testes e Deploy

O pipeline foi dividido em dois jobs: `test` e `deploy` (com `needs: test`), garantindo que o deploy só ocorra após os testes passarem, e apenas em `push` para `main` — nunca em Pull Requests.

## Job de testes

- Runner: `ubuntu-latest`
- Permissões mínimas: `contents: read`
- Python 3.14 (mesma versão do runtime da Lambda)
- Instala `pytest` e `boto3`
- Executa `pytest` no diretório `backend`

## Primeiro problema: região AWS

```
botocore.exceptions.NoRegionError: You must specify a region.
```

O ambiente do GitHub Actions não possuía região AWS configurada. Foi adicionada:

```yaml
env:
  AWS_DEFAULT_REGION: us-east-1
```

## Autenticação via OIDC

Em vez de credenciais tradicionais (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`), foi implementada autenticação via **OIDC**, permitindo que o GitHub Actions obtenha credenciais temporárias através de uma IAM Role, sem armazenar Access Key permanente no repositório.

## Provedor OIDC

```
Provider: https://token.actions.githubusercontent.com
Audience: sts.amazonaws.com
```

## IAM Role

```
Role: github-actions-oidc-role
ARN: arn:aws:iam::696537703431:role/github-actions-oidc-role
```

## Trust Policy

Restrita ao repositório e branch:

```
repo:BarrosAmorim@24548784/cloud-resume-challenge@1353973394:ref:refs/heads/main
```

## Permissões da IAM Role

Política `CloudResumeSAMDeploy`, cobrindo CloudFormation, Lambda, DynamoDB, API Gateway, IAM (`iam:PassRole`) e S3.

## Segundo problema: iam:GetRole

```
not authorized to perform: iam:GetRole
```

A CloudFormation precisava consultar a IAM Role da Lambda, mas a role do GitHub Actions não tinha essa permissão. Foi adicionada `iam:GetRole` à política.

## Aviso de segurança do IAM

O IAM Access Analyzer sinalizou o uso de `iam:PassRole` com `Resource: "*"`, permitindo passar qualquer IAM Role dentro do escopo da política. **Ponto de melhoria identificado**: restringir o recurso para ARNs específicos, aplicando de forma mais rigorosa o princípio do menor privilégio.

## Workflow final

```yaml
name: Backend CI/CD

on:
  push:
    branches:
      - main
    paths:
      - "backend/**"
      - "template.yaml"
      - ".github/workflows/backend.yml"

  pull_request:
    branches:
      - main
    paths:
      - "backend/**"
      - "template.yaml"
      - ".github/workflows/backend.yml"

jobs:
  test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    env:
      AWS_DEFAULT_REGION: us-east-1
    steps:
      - name: Checkout do codigo
        uses: actions/checkout@v6
      - name: Configurar Python
        uses: actions/setup-python@v6
        with:
          python-version: "3.14"
      - name: Instalar dependencias
        run: |
          python -m pip install --upgrade pip
          pip install pytest boto3
      - name: Executar testes
        working-directory: backend
        run: pytest

  deploy:
    needs: test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    env:
      AWS_DEFAULT_REGION: us-east-1
    steps:
      - name: Checkout do codigo
        uses: actions/checkout@v6
      - name: Configurar Python
        uses: actions/setup-python@v6
        with:
          python-version: "3.14"
      - name: Configurar AWS SAM CLI
        uses: aws-actions/setup-sam@v2
      - name: SAM Build
        run: sam build
      - name: Configurar credenciais AWS via OIDC
        uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: arn:aws:iam::696537703431:role/github-actions-oidc-role
          aws-region: us-east-1
      - name: Testar acesso AWS
        run: aws sts get-caller-identity
      - name: SAM Deploy
        run: sam deploy --no-confirm-changeset --no-fail-on-empty-changeset
```

## Comportamento em Pull Requests

PRs executam apenas o job `test` — o `deploy` não roda, pois depende de `github.event_name == 'push' && github.ref == 'refs/heads/main'`.

## Validação final

```
test    ✅
deploy  ✅
```

O GitHub Actions passou a: baixar o código, configurar Python, instalar dependências, executar `pytest`, executar `sam build`, autenticar via OIDC, assumir a IAM Role, acessar a AWS, executar `sam deploy` e atualizar a infraestrutura.

## Segurança

Não foram utilizadas credenciais permanentes (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`). Em vez disso, GitHub OIDC → AWS IAM → credenciais temporárias.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
