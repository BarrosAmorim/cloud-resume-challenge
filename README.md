# Cloud Resume Challenge — AWS

Projeto desenvolvido seguindo o **Cloud Resume Challenge**, com o objetivo de construir um currículo utilizando serviços da AWS e práticas de Cloud e DevOps.

## Objetivo

Criar e disponibilizar um currículo online utilizando serviços de nuvem, infraestrutura como código, controle de versão e CI/CD.

O projeto será desenvolvido seguindo as etapas propostas pelo desafio.

## Tecnologias

- HTML
- CSS
- Git
- GitHub
- AWS
- Terraform
- Python
- Docker
- GitHub Actions

> As tecnologias serão adicionadas ao projeto conforme cada etapa for implementada.

## Estrutura do projeto

```text
cloud-resume-challenge/
└── frontend/
    ├── index.html
    └── style.css
```

## Etapas do projeto

- [x] Certificação AWS
- [x] HTML
- [x] CSS
- [x] Static Website — Amazon S3
- [x] HTTPS — CloudFront
- [ ] DNS
- [ ] JavaScript
- [ ] Banco de dados — DynamoDB
- [ ] API — API Gateway
- [ ] Backend — Python/Lambda
- [ ] Testes
- [ ] Infrastructure as Code
- [x] Controle de versão — Git/GitHub
- [ ] CI/CD — Backend
- [ ] CI/CD — Frontend
- [ ] Documentação do projeto

---

# Documentação das etapas

## Etapa 1 — Certificação AWS

### Objetivo

Concluir uma certificação AWS antes de iniciar o desenvolvimento do projeto.

### O que foi feito

Já possuía a certificação **AWS Certified Cloud Practitioner**, concluída em julho de 2026.

### Resultado

A etapa de certificação foi concluída antes do início da implementação do projeto.

---

## Etapa 2 — HTML

### Objetivo

Criar o currículo utilizando HTML.

### Passo a passo

1. Criei a estrutura HTML do currículo.
2. Defini o idioma da página como `pt-BR`.
3. Adicionei a estrutura básica do documento HTML.
4. Criei as seções do currículo utilizando elementos semânticos.
5. Adicionei informações profissionais, experiência, competências, projetos, certificações e formação.
6. Criei o arquivo `index.html` dentro da pasta `frontend`.

### Estrutura utilizada

```text
frontend/
└── index.html
```

### Resultado

Foi criado o currículo utilizando HTML, com estrutura organizada e elementos semânticos.

### Status

Concluído.

---

## Etapa 3 — CSS

### Objetivo

Aplicar estilos ao currículo utilizando CSS.

### Passo a passo

1. Criei o arquivo `style.css`.
2. Adicionei o arquivo dentro da pasta `frontend`.
3. Vinculei o CSS ao arquivo `index.html`.
4. Configurei fonte, espaçamento, margens e tamanhos.
5. Criei estilos para títulos, seções, listas e informações do currículo.
6. Adicionei responsividade para diferentes tamanhos de tela.
7. Realizei ajustes visuais para manter o currículo simples e profissional.

### Estrutura utilizada

```text
frontend/
├── index.html
└── style.css
```

### Resultado

O currículo passou a possuir uma apresentação visual organizada e responsiva.

### Status

Concluído.

---

## Etapa 4 — Amazon S3

### Objetivo

Utilizar o Amazon S3 para armazenar os arquivos estáticos do currículo como parte da infraestrutura do projeto na AWS.

### Passo a passo

1. Acessei o console da AWS.
2. Acessei o serviço Amazon S3.
3. Criei um bucket para o projeto.
4. Selecionei a região `South America (São Paulo) — sa-east-1`.
5. Mantive as ACLs desabilitadas.
6. Mantive o bloqueio de acesso público ativado.
7. Adicionei uma tag para identificação do projeto.
8. Realizei o upload do arquivo `index.html`.
9. Realizei o upload do arquivo `style.css`.

### Estrutura do bucket

```text
bucket/
├── index.html
└── style.css
```

### Resultado

O bucket foi criado com sucesso e os arquivos do frontend foram enviados para o Amazon S3.

### Status

Em andamento.

A próxima etapa será configurar o S3 para hospedagem do site estático e realizar os testes de acesso.

### Configuração do Static Website Hosting

Após realizar o upload dos arquivos, habilitei a hospedagem de site estático no bucket S3.

Configurações utilizadas:

- Hospedagem de site estático: ativada
- Tipo de hospedagem: Hospedar um site estático
- Documento de índice: `index.html`
- Documento de erro: não configurado

### Resultado

O Amazon S3 foi configurado para utilizar o `index.html` como página inicial do site.

### Etapa 5 — HTTPS com Amazon CloudFront

#### Objetivo

Disponibilizar o currículo através de HTTPS utilizando o Amazon CloudFront, conforme solicitado pelo Cloud Resume Challenge.

#### Configuração

Foi criada uma distribuição do Amazon CloudFront para entregar o conteúdo do site hospedado no Amazon S3.

Configurações utilizadas:

- Distribution name: `cloud-resume-challenge`
- Plano: `Free ($0/month)`
- Origem: S3 Static Website
- S3 Website Endpoint:
  `cloud-resume-rafael-2026.s3-website-us-east-1.amazonaws.com`
- Origin Shield: desativado
- Cache: configurações recomendadas para conteúdo S3
- WAF: configurações de segurança padrão
- HTTPS: habilitado pelo CloudFront

#### Problema encontrado

Após criar a distribuição, o acesso pelo CloudFront retornava:

```text
403 Forbidden
Code: AccessDenied
Message: Access Denied
```

A mesma situação também ocorria inicialmente ao acessar o Static Website do S3.

#### Diagnóstico

O bucket estava com a opção **Bloquear todo o acesso público** ativada.

Como a implementação desta etapa utiliza o endpoint de **Static Website Hosting do S3**, foi necessário permitir acesso público de leitura aos objetos do bucket.

#### Solução

Foi desativado o bloqueio de acesso público do bucket e criada uma Bucket Policy permitindo somente a ação `s3:GetObject` para os objetos armazenados no bucket.

A política utilizada permite leitura pública dos arquivos necessários para o funcionamento do currículo, sem conceder permissões de upload, alteração ou exclusão.

#### Testes realizados

1. Acesso ao endpoint do Static Website do S3:
   - Resultado: currículo carregado com sucesso.

2. Acesso através do CloudFront:
   - URL: `https://d189fig617ch0u.cloudfront.net`
   - Resultado: currículo carregado com sucesso.

3. HTTPS:
   - Resultado: conexão HTTPS funcionando corretamente através do CloudFront.

#### Arquitetura

```text
Usuário
   |
   | HTTPS
   v
Amazon CloudFront
   |
   | HTTP
   v
Amazon S3
Static Website Hosting
   |
   v
index.html + style.css
```

> Observação: o endpoint de Static Website do S3 utiliza HTTP. O HTTPS para o usuário final é fornecido pelo CloudFront.

#### Status

**Concluído ✅**

---

## Objetivo profissional

Utilizar o projeto como laboratório prático para desenvolver e demonstrar conhecimentos em **Cloud Computing, AWS, infraestrutura, automação, DevOps e CI/CD**.

## Status do projeto

🚧 Projeto em desenvolvimento.

O projeto será atualizado conforme cada etapa do Cloud Resume Challenge for implementada, testada e documentada.
