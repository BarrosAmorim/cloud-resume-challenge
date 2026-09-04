# Etapa 13 — CI/CD (Front-end)

## Objetivo

Configurar um pipeline de **CI/CD para o frontend** utilizando GitHub Actions, publicando automaticamente na AWS as alterações realizadas no código do currículo, sem acessar o console ou executar comandos manuais.

```
Alteração no frontend → git push → GitHub → GitHub Actions
   → OIDC → AWS → S3 → CloudFront → Currículo online
```

## Por que um workflow separado?

O `backend.yml` monitora `backend/**` e `template.yaml`. Alterações no frontend não devem acionar o pipeline de backend, e vice-versa. Foi criado `.github/workflows/frontend.yml`, com filtros próprios:

```yaml
paths:
  - "frontend/**"
  - ".github/workflows/frontend.yml"
```

> O desafio oficial recomenda um segundo repositório para o frontend. Neste projeto foi adotada uma adaptação, mantendo frontend e backend no mesmo repositório, mas com pipelines independentes.

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
│   ├── style.css
│   └── script.js
│
├── template.yaml
├── samconfig.toml
├── README.md
│
└── .github/
    └── workflows/
        ├── backend.yml
        └── frontend.yml
```

## Primeiro teste do workflow

Foi criado um job inicial só para verificar acesso ao repositório e localização do frontend:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout do codigo
        uses: actions/checkout@v6
      - name: Verificar frontend
        run: |
          echo "Frontend encontrado"
          ls -la frontend
```

## Autenticação com AWS via OIDC

```
GitHub Actions → Token OIDC → GitHub OIDC Provider → AWS IAM
   → IAM Role → Credenciais temporárias → S3 / CloudFront
```

## IAM Role dedicada ao frontend

Foi criada uma Role própria, separada da role do backend:

```
github-actions-frontend-oidc-role
```

## Trust Policy

Problema inicial: `Not authorized to perform sts:AssumeRoleWithWebIdentity`. A Trust Policy não correspondia ao `sub` correto enviado pelo GitHub OIDC.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:BarrosAmorim@<OWNER_ID>/cloud-resume-challenge@<REPOSITORY_ID>:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

Restringir a condição `sub` evita que repositórios não autorizados assumam a Role.

## Política de permissões

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3BucketAccess",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::cloud-resume-rafael-2026"
    },
    {
      "Sid": "S3ObjectAccess",
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::cloud-resume-rafael-2026/*"
    },
    {
      "Sid": "CloudFrontInvalidation",
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "arn:aws:cloudfront::<AWS_ACCOUNT_ID>:distribution/EPIQFSJKWMN9X"
    }
  ]
}
```

Permissões limitadas ao bucket `cloud-resume-rafael-2026` e à distribuição CloudFront `EPIQFSJKWMN9X` utilizados pelo projeto — sem acesso geral a outros recursos da conta.

## Workflow final

```yaml
name: Frontend CI/CD

on:
  push:
    branches:
      - main
    paths:
      - "frontend/**"
      - ".github/workflows/frontend.yml"

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    env:
      AWS_DEFAULT_REGION: us-east-1
    steps:
      - name: Checkout do codigo
        uses: actions/checkout@v6
      - name: Configurar credenciais AWS via OIDC
        uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: arn:aws:iam::<AWS_ACCOUNT_ID>:role/github-actions-frontend-oidc-role
          aws-region: us-east-1
      - name: Testar acesso AWS
        run: aws sts get-caller-identity
      - name: Publicar frontend no S3
        run: aws s3 sync frontend/ s3://cloud-resume-rafael-2026 --delete
      - name: Invalidar cache do CloudFront
        run: aws cloudfront create-invalidation --distribution-id EPIQFSJKWMN9X --paths "/*"
```

`id-token: write` permite que o workflow solicite o token OIDC do GitHub (por si só não concede acesso à AWS). O `aws-actions/configure-aws-credentials` troca esse token por credenciais temporárias.

## Publicação no S3

```
aws s3 sync frontend/ s3://cloud-resume-rafael-2026 --delete
```

O parâmetro `--delete` remove do bucket objetos que não estão mais presentes na origem, mantendo o conteúdo alinhado com o repositório.

## Invalidação do CloudFront

```
aws cloudfront create-invalidation --distribution-id EPIQFSJKWMN9X --paths "/*"
```

Garante que o CloudFront descarte o cache e sirva a versão atualizada do site.

## Teste real do CI/CD

Foi feita uma pequena alteração em `frontend/index.html`, seguida de `git push`. O GitHub Actions executou automaticamente:

```
Checkout                  ✅
Autenticação OIDC         ✅
Acesso AWS                ✅
Upload para S3            ✅
Invalidação CloudFront    ✅
```

A alteração apareceu corretamente no currículo publicado após um recarregamento completo do navegador.

## Segurança

Não foram utilizadas credenciais permanentes da AWS no GitHub. Em vez disso: GitHub Actions → OIDC → IAM Role → credenciais temporárias → AWS. A Trust Policy foi restringida ao repositório e branch do projeto, e as permissões da Role foram limitadas aos recursos S3 (`cloud-resume-rafael-2026`) e CloudFront (`EPIQFSJKWMN9X`) utilizados.

## Diferença entre os pipelines

```
Backend:  backend/ + template.yaml → backend.yml  → Testes, SAM Build, SAM Deploy → AWS
Frontend: frontend/                → frontend.yml → OIDC, S3 Sync, CloudFront Invalidation → Currículo online
```

## Resultado

A implementação do CI/CD do frontend foi concluída e validada de ponta a ponta: alterações em `frontend/`, ao serem enviadas para `main`, são publicadas automaticamente no S3 e refletidas no currículo online via invalidação do CloudFront.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
