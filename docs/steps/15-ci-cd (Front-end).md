# Step 15: CI/CD do Front-end

## 1. Visão Geral
Implementação da esteira de Entrega Contínua (CD) para os arquivos estáticos do front-end (`index.html`, `styles.css`, `script.js` e assets). A esteira automatiza a sincronização dos arquivos alterados diretamente com o bucket S3 de hospedagem e dispara a invalidação de cache na CDN do Amazon CloudFront, permitindo que alterações visuais e funcionais fiquem disponíveis globalmente em tempo real.

Toda a autenticação foi construída utilizando federação de identidade via **OIDC (OpenID Connect)** com o AWS STS, eliminando credenciais estáticas (`AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY`).

---

## 2. Infraestrutura como Código (Terraform)

Para conceder as permissões necessárias ao runner do GitHub Actions sem elevar privilégios desnecessários, estendemos a Role IAM existente (`cloud-resume-github-actions-role`) no arquivo `terraform/oidc.tf`.

### Recursos adicionados em `terraform/oidc.tf`:

```hcl
# 6. Politica de Menor Privilegio para Frontend (S3 Sync + CloudFront Invalidation)
resource "aws_iam_policy" "github_actions_frontend_policy" {
  name        = "cloud-resume-github-actions-frontend-policy"
  description = "Permite ao GitHub Actions sincronizar arquivos no S3 e invalidar o CloudFront"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3SyncPermissions"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.resume_bucket.arn,
          "${aws_s3_bucket.resume_bucket.arn}/*"
        ]
      },
      {
        Sid    = "CloudFrontInvalidation"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = aws_cloudfront_distribution.s3_distribution.arn
      }
    ]
  })
}

# 7. Anexar a politica de frontend a Role existente do GitHub Actions
resource "aws_iam_role_policy_attachment" "github_actions_frontend_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_frontend_policy.arn
}

# 8. Output do ID da distribuicao CloudFront
output "cloudfront_distribution_id" {
  description = "ID da distribuicao CloudFront para a pipeline de front-end"
  value       = aws_cloudfront_distribution.s3_distribution.id
}
```

* **Permissões S3:** Restritas exclusivamente ao bucket `cloud-resume-challenge-rafael` e seus objetos para leitura, escrita, listagem e remoção de artefatos obsoletos.
* **Permissões CloudFront:** Limitadas à ação `cloudfront:CreateInvalidation` exclusivamente sobre o ARN da distribuição do projeto (`E23LS84QN40NHF`).

---

## 3. Workflow de CI/CD (GitHub Actions)

Criado o arquivo de automação `.github/workflows/frontend-cicd.yml` para orquestrar a publicação contínua.

### Arquivo criado: `.github/workflows/frontend-cicd.yml`

```yaml
name: Frontend CI/CD

on:
  push:
    branches:
      - main
    paths:
      - 'frontend/**'
      - '.github/workflows/frontend-cicd.yml'
  workflow_dispatch:

permissions:
  id-token: write # Necessário para solicitar o JWT do OIDC
  contents: read  # Permite ao runner fazer checkout do código

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::696537703431:role/cloud-resume-github-actions-role
          aws-region: us-east-1

      - name: Sync static files to S3
        run: |
          aws s3 sync frontend/ s3://cloud-resume-challenge-rafael \
            --delete \
            --cache-control "public, max-age=0, must-revalidate"

      - name: Invalidate CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id E23LS84QN40NHF \
            --paths "/*"
```

---

## 4. Decisões Técnicas de Engenharia

1. **Filtragem de Gatilhos (`paths`):**
   * A pipeline só roda quando arquivos dentro de `frontend/` ou o próprio arquivo de workflow são modificados, poupando minutos de runner.
2. **Flag `--delete` no S3 Sync:**
   * Garante que arquivos removidos ou renomeados no repositório sejam expurgados do bucket, evitando arquivos órfãos em produção.
3. **Diretiva de Cache HTTP (`Cache-Control`):**
   * `public, max-age=0, must-revalidate`: instrui os navegadores a validar a versão com o CloudFront antes de exibir o cache local, impedindo que visitantes vejam versões desatualizadas de assets e scripts.
4. **Purge Global de Cache (`cloudfront create-invalidation`):**
   * A invalidação com o path `/*` força todos os Edge Locations da CDN a descartar o cache em borda e buscar o conteúdo novo diretamente do S3.

---

## 5. Testes e Validação Prática

1. **Aplicação do Terraform:** A nova política de permissões IAM e o output foram provisionados via `terraform apply -auto-approve`.
2. **Disparo Automático:** O envio do workflow para a branch `main` ativou a esteira no GitHub Actions.
3. **Execução das Etapas:**
   - Autenticação federada OIDC efetuada com sucesso sem chaves estáticas.
   - Sincronização dos arquivos estáticos com o bucket `cloud-resume-challenge-rafael`.
   - Invalidação de cache submetida com sucesso para a distribuição `E23LS84QN40NHF`.
4. **Disponibilidade:** Conteúdo verificado diretamente na URL de produção `https://d26is0r520jrs6.cloudfront.net` (e no domínio customizado).