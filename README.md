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
- [x] DNS
- [x] JavaScript
- [x] Banco de dados — DynamoDB
- [x] API — API Gateway
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

### Status

**Concluído ✅**

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

**Concluído ✅**

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

**Concluído ✅**

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

### Status

**Concluído ✅**

---

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

## Etapa 6 — DNS

### Objetivo

Configurar um domínio personalizado para o currículo e disponibilizá-lo através de HTTPS utilizando Amazon CloudFront, AWS Certificate Manager (ACM) e Cloudflare DNS.

### Serviços utilizados

- Amazon CloudFront
- AWS Certificate Manager (ACM)
- Cloudflare DNS
- Amazon S3

### Passo a passo

1. Utilizei o domínio `barrosamorimd.work` para o projeto.

2. Solicitei um certificado SSL/TLS para o domínio através do AWS Certificate Manager (ACM), utilizando a região `us-east-1`, necessária para utilização do certificado com o CloudFront.

3. O ACM forneceu um registro CNAME para validação do domínio.

4. Criei o registro CNAME de validação no Cloudflare e configurei como **DNS Only**.

5. Realizei verificações de DNS para confirmar se o registro de validação estava sendo publicado corretamente pelos servidores autoritativos do Cloudflare.

6. Após a validação, o certificado foi emitido pelo ACM.

7. Configurei `barrosamorimd.work` como **Alternate domain name (CNAME)** na distribuição do Amazon CloudFront.

8. Associei o certificado SSL/TLS emitido pelo ACM à distribuição CloudFront.

9. Configurei a política de segurança TLS da distribuição como `TLSv1.2_2021`.

10. Criei no Cloudflare o registro CNAME principal do domínio, apontando:

```text
barrosamorimd.work
        ↓
d189fig617ch0u.cloudfront.net
```

11. Mantive o registro como **DNS Only**, permitindo que o DNS do Cloudflare apenas direcionasse o domínio para o CloudFront.

12. Durante a configuração, o domínio apresentou inicialmente o erro `DNS_PROBE_FINISHED_NXDOMAIN`.

13. Utilizei o comando `nslookup` para investigar a resolução DNS:

```bash
nslookup barrosamorimd.work 1.1.1.1
```

14. O teste confirmou que o domínio estava sendo resolvido corretamente para os endereços da infraestrutura do CloudFront.

15. Realizei o teste final acessando:

```text
https://barrosamorimd.work
```

### Arquitetura

```text
Usuário
   │
   │ HTTPS
   ▼
barrosamorimd.work
   │
   │ DNS / CNAME
   ▼
Amazon CloudFront
   │
   │ HTTP
   ▼
Amazon S3
   │
   ├── index.html
   └── style.css
```

### Troubleshooting

Durante a configuração do domínio, o acesso apresentou inicialmente:

```text
DNS_PROBE_FINISHED_NXDOMAIN
```

O problema foi investigado utilizando `nslookup` e consultas aos registros DNS.

Após a configuração correta do CNAME do domínio para a distribuição CloudFront, a resolução DNS passou a funcionar:

```text
barrosamorimd.work
        ↓
d189fig617ch0u.cloudfront.net
```

O acesso HTTPS foi então validado com sucesso.

### Resultado

O currículo passou a estar disponível através de um domínio personalizado e protegido por HTTPS.

**URL do projeto:**

`https://barrosamorimd.work`

A configuração demonstra a utilização integrada de **DNS, certificado SSL/TLS, CloudFront e S3**, incluindo diagnóstico e resolução de problemas de DNS.

### Status

**Concluído ✅**

## Etapa 7 — JavaScript

### Objetivo

Adicionar um contador de visitantes ao currículo utilizando JavaScript, preparando a aplicação para posteriormente buscar e atualizar esse valor através de uma API.

### Passo a passo

1. Adicionei uma área no `footer` do currículo para exibir a quantidade de visitantes.

2. Criei o elemento HTML `span` com o identificador `visitor-count` para permitir que o JavaScript alterasse o valor dinamicamente.

3. Inicialmente, defini o contador com o valor `0` no HTML.

4. Criei o arquivo `script.js` dentro da pasta `frontend`.

5. Utilizei JavaScript para localizar o elemento `visitor-count` através do método `getElementById()`.

6. Configurei o JavaScript para alterar o valor exibido no contador para `1`.

7. Vinculei o arquivo `script.js` ao `index.html` através da tag:

```html
<script src="script.js"></script>
```

8. Salvei os arquivos e realizei um teste localmente através do navegador.

9. O teste confirmou que o JavaScript foi carregado corretamente e conseguiu alterar o valor exibido no HTML.

### Estrutura utilizada

```text
frontend/
├── index.html
├── style.css
└── script.js
```

### Resultado

Foi implementada a primeira versão do contador de visitantes utilizando JavaScript.

O contador atualmente utiliza um valor fixo para validar a integração entre HTML e JavaScript. Nas próximas etapas, esse valor será substituído por uma contagem armazenada no DynamoDB e acessada através de uma API.

### Status

Em andamento.

---

## Etapa 8 — Banco de dados

### Objetivo

Criar um banco de dados para armazenar a quantidade de visitantes do currículo, utilizando o Amazon DynamoDB em modo de capacidade sob demanda.

### Serviço utilizado

- Amazon DynamoDB

### Passo a passo

1. Acessei o serviço Amazon DynamoDB através do console da AWS.

2. Selecionei a opção para criar uma nova tabela.

3. Criei a tabela com o nome:

```text id="e6s0s6"
CloudResumeVisitorCount
```

4. Configurei a chave de partição da tabela como:

```text id="4bgjwl"
id
```

5. Defini o tipo da chave de partição como `String`.

6. Não utilizei chave de classificação, pois o projeto necessita apenas de um registro para armazenar a contagem de visitantes.

7. Mantive a classe da tabela como **DynamoDB Standard**.

8. Configurei o modo de capacidade como **Sob demanda (On-Demand)**, evitando a necessidade de definir previamente unidades de leitura e gravação.

9. Mantive as configurações padrão de criptografia utilizando uma chave de propriedade da AWS.

10. Adicionei uma tag para identificar o recurso:

```text id="a0gq67"
Project = CloudResumeChallenge
```

11. Criei a tabela e aguardei até que seu status fosse alterado para **Ativa**.

12. Acessei a opção de exploração dos itens da tabela.

13. Criei o primeiro item para armazenar a contagem de visitantes.

14. Configurei a chave de partição do item como:

```text id="s7hmbw"
id = "visitor-count"
```

15. Adicionei o atributo responsável pela quantidade de visitantes:

```text id="1k8i2q"
count = 0
```

### Estrutura da tabela

```text id="ax1n9t"
CloudResumeVisitorCount

┌────────────────┬───────┐
│ id             │ count │
├────────────────┼───────┤
│ visitor-count  │   0   │
└────────────────┴───────┘
```

### Resultado

Foi criada uma tabela DynamoDB em modo de capacidade sob demanda para armazenar a quantidade de visitantes do currículo.

O item inicial foi criado com a contagem `0`, preparando o banco de dados para que, nas próximas etapas, a aplicação possa consultar e atualizar esse valor através de uma API.

### Status

Concluído ✅

---

## Etapa 9 — API

### Objetivo

Criar uma API para permitir que o currículo se comunique com o banco de dados DynamoDB de forma segura e organizada.

De acordo com o desafio, o código JavaScript do currículo não deve acessar diretamente o DynamoDB. A comunicação deverá ser realizada através de uma API, utilizando o Amazon API Gateway e uma função AWS Lambda.

A arquitetura planejada para esta etapa é:

```text
Navegador
    │
    │ JavaScript
    │ HTTP GET
    ▼
Amazon API Gateway
    │
    │ GET /count
    ▼
AWS Lambda
    │
    │ leitura / atualização
    ▼
Amazon DynamoDB
    │
    ▼
CloudResumeVisitorCount
```

### Serviços utilizados

- Amazon API Gateway
- AWS Lambda
- Amazon DynamoDB

### Passo a passo

1. Acessei o serviço **Amazon API Gateway** através do console da AWS.

2. Selecionei a opção para criar uma nova API.

3. Escolhi o tipo:

```text
API HTTP
```

A opção foi escolhida por ser adequada para uma API simples que será utilizada pelo currículo para realizar requisições HTTP.

4. Defini o nome da API como:

```text
CloudResumeAPI
```

5. Configurei o tipo de endereço IP como:

```text
IPv4
```

6. Inicialmente, a API foi criada sem uma integração, pois a função Lambda ainda será criada e configurada posteriormente.

7. Após a criação da API, acessei a área de **Rotas**.

8. Criei uma rota específica para o contador de visitantes.

9. Configurei o método HTTP como:

```text
GET
```

10. Configurei o caminho da rota como:

```text
/count
```

A rota criada ficou:

```text
GET /count
```

11. A rota será utilizada posteriormente pelo JavaScript do currículo para solicitar a quantidade atual de visitantes.

12. A API utiliza o estágio padrão:

```text
$default
```

13. Mantive a opção de **implantação automática** habilitada no estágio `$default`.

Com isso, as alterações realizadas na API podem ser disponibilizadas automaticamente nesse estágio.

### Configuração atual

```text
API
└── CloudResumeAPI

Tipo
└── HTTP API

Endereço IP
└── IPv4

Estágio
└── $default
    └── Implantação automática: habilitada

Rotas
└── GET /count
```

### Arquitetura planejada

```text
┌─────────────────────────┐
│      Site / Currículo   │
│                         │
│       JavaScript        │
└────────────┬────────────┘
             │
             │ GET /count
             ▼
┌─────────────────────────┐
│      API Gateway        │
│                         │
│    CloudResumeAPI       │
│       GET /count        │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│        Lambda           │
│                         │
│  Processa a requisição  │
└────────────┬────────────┘
             │
             │ leitura / atualização
             ▼
┌─────────────────────────┐
│       DynamoDB          │
│                         │
│ CloudResumeVisitorCount │
│                         │
│ id: visitor-count       │
│ count: 0                │
└─────────────────────────┘
```

### Por que utilizar uma API?

O JavaScript do navegador não deve acessar diretamente o DynamoDB.

A API cria uma camada intermediária entre o usuário e o banco de dados.

Dessa forma:

```text
JavaScript
    ↓
API Gateway
    ↓
Lambda
    ↓
DynamoDB
```

A Lambda será responsável por processar a requisição e realizar as operações necessárias no DynamoDB.

Essa arquitetura também permite controlar melhor as permissões de acesso ao banco de dados, evitando disponibilizar credenciais ou acesso direto ao DynamoDB no código executado pelo navegador.

### Estado atual

A API e a rota já foram criadas, porém a integração com a Lambda ainda não foi configurada.

### Próximos passos

- Criar a função AWS Lambda.
- Configurar a integração entre API Gateway e Lambda.
- Permitir que a Lambda acesse o DynamoDB.
- Testar a rota `GET /count`.
- Retornar a quantidade de visitantes para o navegador.
- Posteriormente substituir o contador fixo do `script.js` pelo valor retornado pela API.

### Status

Em andamento.

---

## Objetivo profissional

Utilizar o projeto como laboratório prático para desenvolver e demonstrar conhecimentos em **Cloud Computing, AWS, infraestrutura, automação, DevOps e CI/CD**.

## Status do projeto

🚧 Projeto em desenvolvimento.

O projeto será atualizado conforme cada etapa do Cloud Resume Challenge for implementada, testada e documentada.
