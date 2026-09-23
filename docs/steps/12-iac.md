# Step 12: Infrastructure as Code (Terraform)

## Abordagem do Projeto
Diferente da progressão linear tradicional que utiliza cliques manuais no console da AWS para depois migrar para código, este projeto adotou **Infraestrutura como Código (IaC) como princípio fundamental desde a Etapa 1**.

Toda a infraestrutura necessária — frontend (S3, OAC, CloudFront, ACM), backend (DynamoDB, Lambda, API Gateway) e governança (políticas IAM de menor privilégio) — foi 100% provisionada e gerenciada através do HashiCorp Terraform.

## Validação de Resiliência e Reprodutibilidade
Para comprovar a fidelidade do código e a ausência de dependências manuais (*ClickOps*):
1. Foi executado um `terraform destroy` completo de toda a pilha (18 recursos gerenciados).
2. A pilha foi integralmente reconstruída via `terraform apply` a partir do estado remoto persistido em bucket S3 com bloqueio de concorrência via DynamoDB.
3. A aplicação retornou ao ar de forma automatizada, comprovando a reproducibilidade total da solução.