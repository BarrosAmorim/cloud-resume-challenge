# Etapa 01: Certification

## 1. Objetivo
- Cumprir o pré-requisito formal do Cloud Resume Challenge validando meu conhecimento teórico e prático sobre a nuvem AWS.
- Garantir que eu entenda a base de segurança, custos e arquitetura antes de criar qualquer recurso na conta.

## 2. Conceitos e Decisões Técnicas
- **Modelo de Responsabilidade Compartilhada:** A AWS cuida da segurança da nuvem (hardware, data centers e infraestrutura física). Eu sou o único responsável pela segurança na nuvem (IAM, senhas, criptografia, regras de firewall e dados).
- **Princípio do Menor Privilégio:** Dar apenas o acesso mínimo necessário para cada usuário ou serviço realizar sua tarefa, evitando permissões excessivas.
- **Segurança da Conta:**
  - **Laboratório (Antipadrão a evitar):** Usar o usuário Root no cotidiano ou criar chaves de acesso permanentes com permissão de administrador geral anexada. Isso cria um risco crítico de segurança.
  - **Boa prática:** Bloquear o usuário Root com MFA físico/aplicativo e guardá-lo apenas para tarefas exclusivas de emergência ou faturamento. Operar no dia a dia com usuário/função de menor privilégio e configurar alertas no AWS Budgets antes de subir qualquer serviço.

## 3. Estado Atual da Arquitetura
```text
[ Desenvolvedor ]
       |
       | (Usuário IAM / MFA / Menor Privilégio)
       v
  [ Conta AWS ]
       |
       +---> [ AWS Budgets / Alerta de Custo ]
       |
       +---> (Nenhum recurso criado ainda)