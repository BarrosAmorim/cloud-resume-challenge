# 1. Provedor de Identidade OIDC para o GitHub Actions
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
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