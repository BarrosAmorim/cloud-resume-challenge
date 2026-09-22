# Etapa 04: Static Website com Terraform (Amazon S3)

## 1. Objetivo
- Provisionar o bucket de armazenamento de objetos no Amazon S3 via Infraestrutura como Código (IaC) com Terraform.
- Aplicar a estratégia *Security by Default* (bloqueio total de acesso público), mantendo o bucket 100% privado para integração via CloudFront (OAC).
- Automatizar o upload dos artefatos estáticos (`index.html` e `style.css`) definindo metadados corretos de `Content-Type` e hash MD5 para controle de idempotência.

---

## 2. Decisão Arquitetural: Migração para IaC (Terraform)

- **Contexto:** Inicialmente os recursos foram testados via AWS CLI. No entanto, o padrão de mercado para ambientes reprodutíveis, versionáveis e auditáveis é a **Infraestrutura como Código (IaC)**.
- **Ação:** O bucket criado manualmente foi esvaziado e destruído via CLI (`aws s3 rb --force`) para permitir que o Terraform assumisse o ciclo de vida completo da infraestrutura sem drift ou artefatos órfãos.
- **Ambiente:** Raspberry Pi 4 (arquitetura `linux_arm64`) executando o binário do Terraform v1.16.2.

---

## 3. Preparação do Repositório e Segurança do Estado

### 3.1. Estruturação de Pastas
Criação do diretório exclusivo para os arquivos declarativos da infraestrutura:

```bash
cd ~/projects/cloud-resume-challenge
mkdir -p terraform
```

### 3.2. Proteção de Arquivos de Estado no `.gitignore`
Arquivos de estado local (`.tfstate`) contêm metadados sensíveis da infraestrutura e nunca devem ser enviados ao repositório remoto:

```bash
cat << 'EOF' >> .gitignore

# Terraform
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
EOF
```

---

## 4. Declaração e Execução com Terraform

### 4.1. Configuração do Provedor AWS (`terraform/providers.tf`)
Declaração da versão mínima do Terraform, do provedor AWS e tags padrão para rastreabilidade de custos e propriedade:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "CloudResumeChallenge"
      ManagedBy = "Terraform"
    }
  }
}
```

### 4.2. Inicialização do Diretório (`terraform init`)
Baixa o plugin do provedor AWS compilado para arquitetura ARM64 e cria o lockfile de dependências:

```bash
cd ~/projects/cloud-resume-challenge/terraform
terraform init
```

*Saída de sucesso:*
```text
Terraform has been successfully initialized!
```

---

### 4.3. Declaração dos Recursos S3 (`terraform/s3.tf`)
O arquivo gerencia o bucket, as travas de segurança pública e o upload versionado dos arquivos estáticos:

```hcl
# 1. Bucket S3 para armazenar os arquivos estáticos do site
resource "aws_s3_bucket" "resume_bucket" {
  bucket = "cloud-resume-challenge-rafael"
}

# 2. Bloqueio rigoroso de acesso público (Security by Default)
resource "aws_s3_bucket_public_access_block" "resume_bucket_pab" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Upload do index.html com Content-Type explícito
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "index.html"
  source       = "${path.module}/../frontend/index.html"
  etag         = filemd5("${path.module}/../frontend/index.html")
  content_type = "text/html"
}

# 4. Upload do style.css com Content-Type explícito
resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "style.css"
  source       = "${path.module}/../frontend/style.css"
  etag         = filemd5("${path.module}/../frontend/style.css")
  content_type = "text/css"
}
```

---

### 4.4. Validação e Planejamento (`terraform plan`)
Execução do dry-run para inspecionar o grafo de execução antes da criação dos recursos na nuvem:

```bash
terraform validate
terraform plan
```

*Resultado do plano:*
```text
Plan: 4 to add, 0 to change, 0 to destroy.
```

---

### 4.5. Aplicação da Infraestrutura (`terraform apply`)
Execução do provisionamento efetivo na AWS:

```bash
terraform apply -auto-approve
```

*Resultado:*
```text
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

---

## 5. Auditoria de Permissões e Segurança IAM

- **Identidade Ativa:** O Terraform consumiu as credenciais locais do perfil padrão configuradas no host:
  - **Usuário IAM:** `Barros` (Account: `696537703431`).
  - **Papel:** Credencial administrativa (`AdministratorAccess`) vinculada ao grupo de administradores, permitindo orquestração completa dos serviços de borda e armazenamento.
- **Isolamento do Bucket:** As 4 diretivas do *Block Public Access* garantem que nenhuma leitura anônima direta da internet alcance os arquivos estáticos.

---

## 6. Diagrama da Arquitetura

```text
[ Repositório Local: Raspberry Pi ]
   ├── frontend/ (index.html, style.css)
   └── terraform/ (providers.tf, s3.tf)
            |
            | terraform apply (AWS Provider v5.x / us-east-1)
            v
[ Amazon S3 ]
   Bucket: cloud-resume-challenge-rafael
   ├── Block Public Access: [ATIVO (4/4)]
   ├── index.html (text/html)
   └── style.css  (text/css)
            |
            x (Acesso público direto bloqueado)
```

## 7. Validação Prática e Testes de Segurança

Após aplicar o Terraform, validei o estado real dos recursos no terminal:

### 7.1. Conferir a criação do bucket
```bash
aws s3 ls | grep cloud-resume-challenge-rafael
```

### 7.2. Conferir a existência e integridade dos arquivos
```bash
aws s3 ls s3://cloud-resume-challenge-rafael/
```

*Verificação do Content-Type do HTML:*
```bash
aws s3api head-object --bucket cloud-resume-challenge-rafael --key index.html --query "ContentType" --output text
```
*Retorno:* `text/html`

### 7.3. Confirmar se o bucket está privado

#### Teste A: Verificação das diretivas de bloqueio
```bash
aws s3api get-public-access-block \
  --bucket cloud-resume-challenge-rafael \
  --query "PublicAccessBlockConfiguration" \
  --output json
```

*Resultado:*
```json
{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
}
```

#### Teste B: Teste direto de requisição HTTP (curl)
Enviei uma requisição para a URL direta do objeto no S3:

```bash
curl -I [https://cloud-resume-challenge-rafael.s3.us-east-1.amazonaws.com/index.html](https://cloud-resume-challenge-rafael.s3.us-east-1.amazonaws.com/index.html)
```

*Resultado obtido:*
```text
HTTP/1.1 403 Forbidden
x-amz-error-code: AccessDenied
```

O bucket está totalmente inacessível pela internet pública, pronto para receber o tráfego exclusivamente através do CloudFront com Origin Access Control (OAC).