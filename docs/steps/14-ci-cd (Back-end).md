# Step 14: CI/CD do Back-end

## 1. Visão Geral
Implementação da esteira de Integração Contínua e Entrega Contínua (CI/CD) para o back-end em Python da função AWS Lambda. O pipeline automatiza a execução de testes unitários com `pytest` e `moto`, empacota a aplicação e faz o deploy do código diretamente na AWS apenas se todos os testes passarem.

Toda a autenticação foi construída utilizando federação de identidade via **OIDC (OpenID Connect)**, eliminando o uso de credenciais estáticas (`AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY`).

---

## 2. Infraestrutura como Código (Terraform)

Para permitir que os runners do GitHub Actions autentiquem na AWS de forma segura, configuramos o OpenID Connect Provider e a Role IAM diretamente no Terraform.

### Arquivo criado: `terraform/oidc.tf`

```hcl
# 1. Provedor de Identidade OIDC para o GitHub Actions
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "[https://token.actions.githubusercontent.com](https://token.actions.githubusercontent.com)"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f8d264fcd3"]
}

# 2. Role IAM que o GitHub Actions assumirá via OIDC
resource "aws_iam_role" "github_actions_role" {
  name = "cloud-resume-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:BarrosAmorim@24548784/cloud-resume-challenge@*:*",
              "repo:BarrosAmorim/cloud-resume-challenge:*"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Project   = "Cloud Resume Challenge"
    ManagedBy = "Terraform"
  }
}

# 3. Política de Menor Privilégio para Deploy do Backend (Lambda)
resource "aws_iam_policy" "github_actions_backend_policy" {
  name        = "cloud-resume-github-actions-backend-policy"
  description = "Permite ao GitHub Actions atualizar o código da função Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:GetFunction"
        ]
        Resource = aws_lambda_function.visitor_counter.arn
      }
    ]
  })
}

# 4. Anexar a política à Role
resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_backend_policy.arn
}

# 5. Output do ARN da Role para utilizarmos no GitHub Actions
output "github_actions_role_arn" {
  description = "ARN da Role IAM para ser usada no workflow do GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}
```

* **Segurança do Claim `sub`:** Adotado suporte tanto ao formato imutável com ID numérico do GitHub (`repo:BarrosAmorim@24548784/...`) quanto ao padrão tradicional (`repo:BarrosAmorim/...`).
* **Princípio de Menor Privilégio:** A política restringe estritamente as ações a `lambda:UpdateFunctionCode` e `lambda:GetFunction` sobre a função `cloud-resume-visitor-counter`.

---

## 3. Workflow de CI/CD (GitHub Actions)

Criado o arquivo de automação `.github/workflows/backend-cicd.yml` para gerenciar a esteira de testes e entrega contínua.

### Arquivo criado: `.github/workflows/backend-cicd.yml`

```yaml
name: Backend CI/CD

on:
  push:
    branches:
      - main
    paths:
      - 'backend/**'
      - '.github/workflows/backend-cicd.yml'
  workflow_dispatch:

permissions:
  id-token: write # Obrigatório para solicitar o JWT do OIDC
  contents: read  # Permite ao runner fazer checkout do código

jobs:
  test-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.13'
          cache: 'pip'
          cache-dependency-path: 'backend/requirements-dev.txt'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r backend/requirements-dev.txt

      - name: Run unit tests with pytest
        run: |
          cd backend
          pytest -v

      - name: Configure AWS credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::696537703431:role/cloud-resume-github-actions-role
          aws-region: us-east-1

      - name: Package Lambda code
        run: |
          cd backend
          zip lambda_function.zip lambda_function.py

      - name: Deploy to AWS Lambda
        run: |
          aws lambda update-function-code \
            --function-name cloud-resume-visitor-counter \
            --zip-file fileb://backend/lambda_function.zip
```

---

## 4. Decisões Técnicas de Engenharia

1. **Filtragem de Gatilhos (`paths`):**
   * A pipeline só roda quando arquivos dentro de `backend/` ou o próprio arquivo de workflow são modificados, poupando minutos de runner.
2. **Ambiente Python 3.13:**
   * Alinhado exatamente à versão do runtime configurada na AWS Lambda via Terraform, garantindo paridade total entre teste e produção.
3. **Cache de Dependências:**
   * Configurado `cache-dependency-path: 'backend/requirements-dev.txt'` para acelerar o `pip install` nos runners do GitHub sem alertas de arquivos não encontrados.
4. **Deploy Direto com AWS CLI:**
   * Optou-se por empacotar e atualizar via `aws lambda update-function-code`. Isso mantém a Role do GitHub Actions restrita e impede que uma credencial de CI/CD tenha poderes destrutivos sobre recursos críticos de infraestrutura (CloudFront, S3, Route 53).

---

## 5. Testes e Validação Prática

### 5.1. Teste de Sucesso (Caminho Feliz)
* Realizado push contendo os arquivos de configuração.
* Dependências instaladas com sucesso, `pytest` aprovou os dois testes unitários (`test_lambda_handler_increments_counter` e `test_lambda_handler_handles_exception`).
* Token JWT emitido pelo GitHub, assumida a Role IAM na AWS e pacote `.zip` aplicado na Lambda.

### 5.2. Teste de Falha Controlada (Proteção do CI)
Para validar que código quebrado não chega a produção, foi injetado um erro intencional no teste `backend/test_lambda.py`:
```python
assert response["statusCode"] == 999  # Esperado: 500
```
* **Resultado:** O `pytest` capturou a asserção inválida e encerrou o processo com `exit code 1`:
  ```text
  FAILED test_lambda.py::test_lambda_handler_handles_exception - assert 500 == 999
  Error: Process completed with exit code 1.
  ```
* **Comportamento da Esteira:** As etapas seguintes (*Configure AWS credentials*, *Package Lambda code* e *Deploy to AWS Lambda*) foram canceladas automaticamente, garantindo que o código em produção permaneceu intacto.
* O teste foi subsequentemente restaurado para `assert response["statusCode"] == 500`, restabelecendo o status verde da pipeline.