# Cloud Resume Challenge — AWS

Currículo online construído seguindo o **Cloud Resume Challenge**, aplicando na prática conceitos de Cloud Computing, Infraestrutura como Código, back-end serverless e CI/CD na AWS.

🔗 **Site publicado:** [barrosamorimd.work](https://barrosamorimd.work)

---

## Navegação

- [Sobre o projeto](#sobre-o-projeto)
- [Arquitetura](#arquitetura)
- [Tecnologias utilizadas](#tecnologias-utilizadas)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Documentação](#documentação)
- [Resultados](#resultados)
- [Segurança](#segurança)
- [O que estou aprendendo](#o-que-estou-aprendendo)
- [Status do projeto](#status-do-projeto)

---

## Sobre o projeto

O Cloud Resume Challenge é um desafio prático que consiste em construir e publicar um currículo online utilizando serviços de nuvem, infraestrutura como código, controle de versão e CI/CD — do zero até produção.

Este projeto foi desenvolvido inteiramente na AWS, cobrindo desde a certificação inicial até a automação completa do deploy de front-end e back-end.

## Arquitetura

```
Usuário
   │
   │ HTTPS
   ▼
barrosamorimd.work  ──(DNS via Cloudflare)
   │
   ▼
Amazon CloudFront ──(SSL via ACM)
   │
   ▼
Amazon S3 (Static Website Hosting)
   │
   ▼
index.html + style.css + script.js
   │
   │ JavaScript / fetch()
   ▼
Amazon API Gateway ── GET /count
   │
   ▼
AWS Lambda (Python) ── boto3
   │
   ▼
Amazon DynamoDB ── contador de visitantes
```

**CI/CD (dois pipelines independentes via GitHub Actions + OIDC):**

```
Backend                          Frontend
  │                                 │
  git push → backend/**            git push → frontend/**
  │                                 │
  pytest                            AWS OIDC
  │                                 │
  sam build                        S3 sync
  │                                 │
  AWS OIDC → sam deploy            CloudFront invalidation
  │                                 │
  CloudFormation                   Currículo atualizado
  (Lambda, API Gateway, DynamoDB)
```

## Tecnologias utilizadas

**Front-end:** HTML, CSS, JavaScript
**Back-end:** Python (AWS Lambda), Boto3, Pytest
**Infraestrutura AWS:** S3, CloudFront, ACM, DynamoDB, API Gateway (HTTP API), IAM, CloudFormation
**IaC:** AWS SAM
**CI/CD:** GitHub Actions, autenticação via OIDC (sem chaves de longa duração)
**DNS:** Cloudflare
**Versionamento:** Git, GitHub

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
├── .github/
│   └── workflows/
│       ├── backend.yml
│       └── frontend.yml
│
├── template.yaml
├── samconfig.toml
├── docs/
│   └── (detalhamento de cada etapa)
│
└── README.md
```

## Documentação

O processo completo — incluindo passo a passo, comandos utilizados, problemas encontrados e soluções — está documentado etapa por etapa:

| Etapa | Descrição                                                    |
| ----- | ------------------------------------------------------------ |
| 01    | [Certificação AWS](docs/01-certificacao.md)                  |
| 02    | [Front-end — HTML e CSS](docs/02-frontend.md)                |
| 03    | [Amazon S3 — Static Website Hosting](docs/03-s3.md)          |
| 04    | [HTTPS com Amazon CloudFront](docs/04-cloudfront.md)         |
| 05    | [DNS personalizado](docs/05-dns.md)                          |
| 06    | [JavaScript e contador de visitantes](docs/06-javascript.md) |
| 07    | [Banco de dados — DynamoDB](docs/07-dynamodb.md)             |
| 08    | [API — API Gateway](docs/08-api-gateway.md)                  |
| 09    | [Back-end — Python/Lambda](docs/09-lambda.md)                |
| 10    | [Testes automatizados](docs/10-testes.md)                    |
| 11    | [Infrastructure as Code — AWS SAM](docs/11-iac-sam.md)       |
| 12    | [CI/CD — Back-end](docs/12-cicd-backend.md)                  |
| 13    | [CI/CD — Front-end](docs/13-cicd-frontend.md)                |

## Resultados

| Etapa                        | Status                  |
| ---------------------------- | ----------------------- |
| Certificação AWS             | ✅ Concluído            |
| Front-end (HTML/CSS/JS)      | ✅ Concluído            |
| Hospedagem estática (S3)     | ✅ Concluído            |
| HTTPS (CloudFront)           | ✅ Concluído            |
| DNS personalizado            | ✅ Concluído            |
| Banco de dados (DynamoDB)    | ✅ Concluído            |
| API (API Gateway)            | ✅ Concluído            |
| Back-end (Lambda/Python)     | ✅ Concluído            |
| Testes automatizados         | ✅ Concluído (3 passed) |
| Infrastructure as Code (SAM) | ✅ Concluído            |
| CI/CD Back-end               | ✅ Concluído            |
| CI/CD Front-end              | ✅ Concluído            |
| Blog post                    | ⬜ Pendente             |

## Segurança

- Autenticação do GitHub Actions com a AWS via **OIDC**, sem armazenamento de credenciais de longa duração (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`) no repositório.
- Trust Policy das IAM Roles restrita ao repositório e branch específicos.
- Permissões de IAM Role segmentadas por pipeline (backend e frontend possuem roles distintas, cada uma limitada aos recursos que realmente utiliza).
- Bucket S3 com bloqueio de acesso público desativado apenas onde necessário, com política restrita a `s3:GetObject`.
- Ponto de melhoria identificado e documentado: revisar o uso de `iam:PassRole` com `Resource: "*"` para aplicar de forma mais rigorosa o princípio do menor privilégio.

## O que estou aprendendo

Este projeto foi utilizado como laboratório prático para consolidar conhecimentos em:

- Arquitetura serverless na AWS (S3, CloudFront, API Gateway, Lambda, DynamoDB)
- Infrastructure as Code com AWS SAM e CloudFormation
- CI/CD com GitHub Actions e autenticação federada via OIDC
- Testes automatizados em Python com Pytest e mocks
- Diagnóstico e resolução de problemas reais de DNS, IAM e permissões

## Status do projeto

🚧 Em desenvolvimento — próximo passo é a publicação do blog post relatando o processo.
