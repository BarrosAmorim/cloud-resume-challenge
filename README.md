# ☁️ Cloud Resume Challenge — AWS

> Um currículo interativo hospedado na nuvem com contador de visitas em tempo real. Uma solução construída sob o modelo Serverless, provisionada inteiramente via Infraestrutura como Código (Terraform) desde o início e com esteiras de automação que não utilizam credenciais estáticas.

🌐 **Acesse o desafio:** [https://cloudresumechallenge.dev/docs/the-challenge/aws/]

🌐 **Acesse o currículo no ar:** [https://barrosamorimd.work]

---

## 🧭 O Propósito do Projeto

O **Cloud Resume Challenge** é uma iniciativa prática criada por Forrest Brazeal, desenhada para colocar em prática múltiplos pilares de computação em nuvem: desenvolvimento web, infraestrutura, segurança, bancos de dados, testes automatizados e integração contínua.

À primeira vista, o visitante encontra um site simples com meu histórico profissional e um contador dinâmico de acessos. Por baixo do capô, no entanto, opera uma arquitetura orientada a microsserviços e sob demanda (serverless), sem servidores virtuais ociosos, sem custo fixo desnecessário e com proteções de segurança.

---

## 🎯 Minha Escolha Técnica: Terraform desde o Primeiro Dia

O roteiro oficial do desafio sugere que o candidato crie os primeiros recursos (S3, CloudFront, certificados) manualmente pelo Console da AWS, para apenas mais tarde, nos passos finais, traduzir o que foi feito para código.

**Optei por não seguir esse caminho manual.**

Desde o primeiro dia de trabalho, adotei **Infraestrutura como Código (IaC) com Terraform**:

* **Consistência Absoluta:** Cada recurso — do bucket de armazenamento à tabela NoSQL, passando por papéis IAM e permissões do API Gateway — foi descrito em arquivos de configuração antes de existir na AWS.
* **Reprodutibilidade:** Se amanhã for necessário replicar todo esse ecossistema em outra região da AWS ou em outra conta, um simples `terraform apply` reconstrói toda a pilha em poucos minutos.
* **Compreensão Conectiva:** Desenvolver a infraestrutura em código me obrigou a compreender com profundidade como cada política de acesso, cada ARN e cada regra de segurança se entrelaçam nos bastidores.

---

## 🏛️ Desenho da Arquitetura

O sistema é dividido em três camadas desacopladas que operam de forma autônoma:

```text
                  [ Visitante no Navegador ]
                              │
                              ▼ (HTTPS / Borda Global)
                 [ Amazon CloudFront (CDN) ]
                              │
            ┌─────────────────┴─────────────────┐
            │                                   │
            ▼ (Arquivos Estáticos)              ▼ (Requisições da API /api)
     [ Amazon S3 ]                    [ Amazon API Gateway ]
 (Hospedagem de Objetos)                 (HTTP REST Endpoint)
                                                │
                                                ▼
                                         [ AWS Lambda ]
                                     (Python 3.13 / Boto3)
                                                │
                                                ▼ (Atualização Atômica)
                                       [ Amazon DynamoDB ]
                                       (Tabela NoSQL de Visitas)
```

---

## ⚙️ Detalhamento dos Componentes

### 1. Front-end e Distribuição Global
* **Interface Responsiva:** Desenvolvida em HTML5 semântico, CSS moderno e JavaScript puro (Vanilla JS), mantendo o bundle extremamente leve e rápido.
* **Hospedagem Segura (Amazon S3):** O bucket foi configurado sem acesso público direto. Nenhuma requisição externa alcança o S3 sem passar pela CDN.
* **Entrega em Borda (Amazon CloudFront + ACM):** Uma distribuição global entrega o conteúdo por servidores de borda próximos ao usuário final com baixa latência, criptografia ponta a ponta via certificado SSL/TLS emitido pelo AWS Certificate Manager (ACM).

### 2. Back-end Serverless e Persistência
* **Ponto de Entrada (Amazon API Gateway):** Recebe as requisições assíncronas disparadas pelo JavaScript do navegador, com políticas restritas de CORS (Cross-Origin Resource Sharing) para evitar abusos de origens não autorizadas.
* **Computação Sob Demanda (AWS Lambda):** Uma função escrita em **Python 3.13** que só é executada quando uma requisição chega. Ela gerencia a lógica de conexão com o banco e trata potenciais falhas de comunicação de maneira graciosa.
* **Persistência de Dados (Amazon DynamoDB):** Uma tabela NoSQL armazena a contagem. O incremento do valor é feito por meio de uma operação atômica (`ADD`), evitando condições de corrida (race conditions) mesmo que múltiplos usuários visitem o site ao mesmo exato momento.

### 3. Automação e Deploys Contínuos (CI/CD)
Toda alteração de código é entregue de forma automatizada por dois fluxos independentes no **GitHub Actions**:

* **Esteira do Back-end (`backend-cicd.yml`):**
  * Disparada apenas quando há alterações na pasta `backend/`.
  * Configura o runtime Python 3.13 e aproveita o cache de dependências do `requirements-dev.txt`.
  * Executa a bateria de testes unitários com `pytest` e simulação local de serviços AWS com `moto`.
  * **Trava de Segurança:** Se qualquer asserção falhar, a pipeline é interrompida no mesmo instante e nenhum pacote quebrado é enviado para a AWS.
  * Aprovados os testes, empacota o código em `.zip` e atualiza a função Lambda via AWS CLI.

* **Esteira do Front-end (`frontend-cicd.yml`):**
  * Disparada quando arquivos estáticos dentro de `frontend/` são atualizados.
  * Sincroniza os arquivos com o bucket S3 utilizando a diretiva `--delete` (para expurgar arquivos obsoletos) e regras de `Cache-Control`.
  * Cria automaticamente uma invalidação de cache no CloudFront (`/*`), garantindo que qualquer alteração visual ou funcional seja refletida globalmente em segundos.

---

## 🔐 Segurança em Primeiro Lugar: Autenticação Federada via OIDC

Um erro comum em pipelines de CI/CD é cadastrar chaves estáticas de acesso (`AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY`) nos segredos do repositório. Chaves estáticas não expiram sozinhas e representam um risco severo caso vazem.

Para eliminar esse risco, a comunicação entre o GitHub Actions e a AWS foi desenhada utilizando **OpenID Connect (OIDC)**:

1. Quando o runner do GitHub inicia, ele solicita um token de identidade assinado (JWT) diretamente ao GitHub.
2. A AWS valida a assinatura desse token através de um Provedor OIDC configurado no IAM via Terraform.
3. O serviço AWS Security Token Service (STS) assume uma Role IAM dedicada cuja regra restringe a execução exclusivamente a este repositório e à branch `main`.
4. As credenciais geradas são temporárias, duram apenas minutos e possuem permissões de menor privilégio (a esteira do backend só pode alterar a função Lambda, enquanto a do frontend só gerencia o bucket S3 e a invalidação do CloudFront).

---

## 📁 Estrutura do Repositório

O projeto foi organizado de maneira clara e modular:

```text
.
├── .github/
│   └── workflows/
│       ├── backend-cicd.yml       # Pipeline com testes e deploy do código Lambda
│       └── frontend-cicd.yml      # Pipeline com sincronização S3 e invalidação no CloudFront
├── backend/
│   ├── lambda_function.py         # Código Python da função do contador
│   ├── test_lambda.py             # Testes unitários utilizando pytest e moto
│   └── requirements-dev.txt       # Dependências de desenvolvimento e testes
├── frontend/
│   ├── index.html                 # Estrutura semântica do currículo
│   ├── styles.css                 # Folha de estilos visual e responsividade
│   └── script.js                  # Chamada fetch para a API com atualização de DOM
├── terraform/
│   ├── providers.tf               # Versões mínimas e configurações do AWS Provider
│   ├── acm.tf                     # Certificado digital SSL/TLS para conexões HTTPS
│   ├── s3.tf                      # Bucket de armazenamento dos arquivos estáticos
│   ├── cloudfront.tf              # Distribuição global e políticas de cabeçalho
│   ├── dynamodb.tf                # Configuração da tabela NoSQL e chaves
│   ├── lambda.tf                  # Definição da função, runtime e papel IAM de execução
│   ├── api_gateway.tf             # Rotas HTTP, integração com Lambda e CORS
│   ├── oidc.tf                    # Provedor OpenID Connect e Roles seguras para o CI/CD
│   └── outputs.tf                 # Exportação de URLs, IDs e ARNs da infraestrutura
└── docs/
    └── steps/                     # Documentação técnica detalhada de cada etapa
        ├── 14-backend-cicd.md     # Relatório técnico do Step 14
        └── 15-frontend-cicd.md     # Relatório técnico do Step 15
```

---

## 📖 Documentação Detalhada das Etapas

Cada fase do desafio foi registrada passo a passo na pasta [`docs/steps/`](docs/steps/), cobrindo desde a formulação do problema até os comandos executados e lições aprendidas:

* **Etapas 01 a 06:** Configurações de DNS, certificado ACM, S3 e CloudFront
* **Etapas 07 a 10:** Desenvolvimento do contador, tabela DynamoDB, Lambda em Python e testes
* **Etapas 11 a 13:** Infraestrutura completa codificada e provisionada com Terraform
* **Etapa 14:** CI/CD do Back-end com Testes e Autenticação OIDC
* **Etapa 15:** CI/CD do Front-end com Sincronização S3 e Invalidação CloudFront

