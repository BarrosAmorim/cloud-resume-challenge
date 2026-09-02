# Cloud Resume Challenge — AWS

Projeto desenvolvido seguindo o **Cloud Resume Challenge**, com o objetivo de construir um currículo utilizando serviços da AWS e práticas de Cloud e DevOps.

## Objetivo

Criar e disponibilizar um currículo online utilizando serviços de nuvem, infraestrutura como código, controle de versão e CI/CD.

O projeto será desenvolvido seguindo as etapas propostas pelo desafio.

## Tecnologias

- HTML
- CSS
- JavaScript
- Git
- GitHub
- AWS
- Amazon S3
- Amazon CloudFront
- Amazon DynamoDB
- Amazon API Gateway
- AWS Lambda
- Python
- Boto3
- Terraform
- GitHub Actions

> As tecnologias serão adicionadas ao projeto conforme cada etapa for implementada.

## Estrutura do projeto

```text
cloud-resume-challenge/

├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
│
└── README.md
```

## Etapas do projeto

- [x] Certificação AWS
- [x] HTML
- [x] CSS
- [x] Static Website — Amazon S3
- [x] HTTPS — CloudFront
- [x] DNS
- [ ] JavaScript
- [x] Banco de dados — DynamoDB
- [x] API — API Gateway
- [x] Backend — Python/Lambda
- [ ] Testes
- [ ] Infrastructure as Code
- [x] Controle de versão — Git/GitHub
- [ ] CI/CD — Backend
- [ ] CI/CD — Frontend
- [ ] Blog post

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

4. Utilizei a região `us-east-1`.

5. Mantive as ACLs desabilitadas.

6. Inicialmente mantive o bloqueio de acesso público ativado.

7. Adicionei uma tag para identificação do projeto.

8. Realizei o upload do arquivo `index.html`.

9. Realizei o upload do arquivo `style.css`.

### Estrutura do bucket

```text
bucket/

├── index.html
└── style.css
```

### Configuração do Static Website Hosting

Após realizar o upload dos arquivos, habilitei a hospedagem de site estático no bucket S3.

Configurações utilizadas:

- Hospedagem de site estático: ativada
- Tipo de hospedagem: Hospedar um site estático
- Documento de índice: `index.html`
- Documento de erro: não configurado

### Problema encontrado

Inicialmente, o acesso ao Static Website do S3 retornava erro de acesso negado.

O bucket estava configurado com o bloqueio de acesso público ativado.

### Solução

Como a implementação utiliza o endpoint de **Static Website Hosting do S3**, foi necessário desativar o bloqueio de acesso público e posteriormente configurar uma política de bucket permitindo leitura dos objetos.

A política utilizada permite somente:

```text
s3:GetObject
```

para os objetos armazenados no bucket.

Não foram concedidas permissões públicas para upload, alteração ou exclusão dos arquivos.

### Resultado

O Amazon S3 foi configurado para utilizar o `index.html` como página inicial do site e os arquivos estáticos passaram a ser disponibilizados corretamente.

### Status

**Concluído ✅**

---

## Etapa 5 — HTTPS com Amazon CloudFront

### Objetivo

Disponibilizar o currículo através de HTTPS utilizando o Amazon CloudFront, conforme solicitado pelo Cloud Resume Challenge.

### Configuração

Foi criada uma distribuição do Amazon CloudFront para entregar o conteúdo do site hospedado no Amazon S3.

Configurações utilizadas:

- Distribution name: `cloud-resume-challenge`
- Plano: `Free ($0/month)`
- Origem: S3 Static Website
- S3 Website Endpoint:

```text
cloud-resume-rafael-2026.s3-website-us-east-1.amazonaws.com
```

- Origin Shield: desativado
- Cache: configurações recomendadas para conteúdo S3
- WAF: configurações padrão
- HTTPS: habilitado pelo CloudFront

### Problema encontrado

Após criar a distribuição, o acesso pelo CloudFront retornava:

```text
403 Forbidden

Code: AccessDenied

Message: Access Denied
```

A mesma situação também ocorria inicialmente ao acessar o Static Website do S3.

### Diagnóstico

O bucket estava com a opção **Bloquear todo o acesso público** ativada.

Como a implementação desta etapa utiliza o endpoint de **Static Website Hosting do S3**, foi necessário permitir acesso público de leitura aos objetos do bucket.

### Solução

Foi desativado o bloqueio de acesso público do bucket e criada uma Bucket Policy permitindo somente a ação:

```text
s3:GetObject
```

para os objetos armazenados no bucket.

A política permite leitura pública dos arquivos necessários para o funcionamento do currículo, sem conceder permissões de upload, alteração ou exclusão.

### Testes realizados

1. Acesso ao endpoint do Static Website do S3:
   - Resultado: currículo carregado com sucesso.

2. Acesso através do CloudFront:

```text
https://d189fig617ch0u.cloudfront.net
```

- Resultado: currículo carregado com sucesso.

3. HTTPS:
   - Resultado: conexão HTTPS funcionando corretamente através do CloudFront.

### Arquitetura

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

### Status

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

2. Solicitei um certificado SSL/TLS para o domínio através do AWS Certificate Manager, utilizando a região `us-east-1`, necessária para utilização do certificado com o CloudFront.

3. O ACM forneceu um registro CNAME para validação do domínio.

4. Criei o registro CNAME de validação no Cloudflare e configurei como **DNS Only**.

5. Realizei verificações de DNS para confirmar se o registro de validação estava sendo publicado corretamente pelos servidores autoritativos do Cloudflare.

6. Após a validação, o certificado foi emitido pelo ACM.

7. Configurei `barrosamorimd.work` como **Alternate domain name (CNAME)** na distribuição do Amazon CloudFront.

8. Associei o certificado SSL/TLS emitido pelo ACM à distribuição CloudFront.

9. Configurei a política de segurança TLS da distribuição como:

```text
TLSv1.2_2021
```

10. Criei no Cloudflare o registro CNAME principal do domínio, apontando:

```text
barrosamorimd.work
        ↓
d189fig617ch0u.cloudfront.net
```

11. Mantive o registro como **DNS Only**, permitindo que o DNS do Cloudflare apenas direcionasse o domínio para o CloudFront.

12. Durante a configuração, o domínio apresentou inicialmente o erro:

```text
DNS_PROBE_FINISHED_NXDOMAIN
```

13. Utilizei o comando `nslookup` para investigar a resolução DNS:

```bash
nslookup barrosamorimd.work 1.1.1.1
```

14. O teste confirmou que o domínio estava sendo resolvido corretamente para a infraestrutura do CloudFront.

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

```text
https://barrosamorimd.work
```

A configuração demonstra a utilização integrada de **DNS, certificado SSL/TLS, CloudFront e S3**, incluindo diagnóstico e resolução de problemas de DNS.

### Status

**Concluído ✅**

---

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

O contador atualmente utiliza um valor fixo para validar a integração entre HTML e JavaScript.

Nas próximas etapas, esse valor será substituído por uma contagem armazenada no DynamoDB e acessada através de uma API.

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

```text
CloudResumeVisitorCount
```

4. Configurei a chave de partição da tabela como:

```text
id
```

5. Defini o tipo da chave de partição como `String`.

6. Não utilizei chave de classificação, pois o projeto necessita apenas de um registro para armazenar a contagem de visitantes.

7. Mantive a classe da tabela como **DynamoDB Standard**.

8. Configurei o modo de capacidade como **Sob demanda (On-Demand)**.

9. Mantive as configurações padrão de criptografia utilizando uma chave de propriedade da AWS.

10. Adicionei uma tag para identificar o recurso:

```text
Project = CloudResumeChallenge
```

11. Criei a tabela e aguardei até que seu status fosse alterado para **Ativa**.

12. Acessei a opção de exploração dos itens da tabela.

13. Criei o primeiro item para armazenar a contagem de visitantes.

14. Configurei a chave de partição do item como:

```text
id = "visitor-count"
```

15. Adicionei o atributo responsável pela quantidade de visitantes:

```text
count = 0
```

### Estrutura da tabela

```text
CloudResumeVisitorCount

┌────────────────┬───────┐
│ id             │ count │
├────────────────┼───────┤
│ visitor-count  │   0   │
└────────────────┴───────┘
```

### Resultado

Foi criada uma tabela DynamoDB em modo de capacidade sob demanda para armazenar a quantidade de visitantes do currículo.

O item inicial foi criado com a contagem `0`, preparando o banco de dados para que a aplicação possa consultar e atualizar esse valor através de uma API.

### Status

**Concluído ✅**

---

# Etapa 9 — API — Amazon API Gateway

### Objetivo

Criar uma API para permitir que o currículo se comunique com o backend da aplicação.

De acordo com o Cloud Resume Challenge, o JavaScript do currículo não deve acessar diretamente o DynamoDB. A comunicação deve ser realizada através de uma API utilizando o Amazon API Gateway e uma função AWS Lambda.

A arquitetura implementada foi:

```text
Navegador
    │
    │ JavaScript
    │
    │ GET /count
    ▼
Amazon API Gateway
    │
    │ Invoca
    ▼
AWS Lambda
    │
    │ GetItem
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

---

### 9.1 Criação do Amazon API Gateway

Acessei o serviço **Amazon API Gateway** através do console da AWS e criei uma nova API.

Configurações utilizadas:

```text
Nome:
CloudResumeAPI

Tipo:
HTTP API

Região:
us-east-1

Endereço IP:
IPv4
```

Foi escolhido o tipo **HTTP API**, adequado para a comunicação simples necessária neste projeto.

Inicialmente, a API foi criada sem uma integração, pois a função Lambda seria configurada posteriormente.

---

### 9.2 Configuração do estágio

A API utiliza o estágio padrão:

```text
$default
```

A opção de implantação automática foi mantida habilitada:

```text
Implantação automática:
Habilitada
```

Com essa configuração, alterações realizadas na API são automaticamente implantadas no estágio `$default`.

---

### 9.3 Criação da rota

Após criar a API, acessei a área de **Rotas** e criei a rota responsável pelo contador de visitantes.

Configuração:

```text
Método HTTP:
GET

Caminho:
/count
```

A rota criada ficou:

```text
GET /count
```

O objetivo dessa rota é permitir que o frontend solicite o valor atual do contador de visitantes.

---

### 9.4 Criação da integração com Lambda

Inicialmente, a rota `/count` não possuía nenhuma integração configurada.

Foi utilizada a opção:

```text
Criar e anexar uma integração
```

A integração foi configurada utilizando:

```text
Tipo de integração:
Função do Lambda

Região:
us-east-1

Função do Lambda:
cloud-resume-counter
```

Depois da configuração, o fluxo da rota passou a ser:

```text
GET /count
     │
     ▼
API Gateway
     │
     ▼
cloud-resume-counter
```

---

### 9.5 Permissão para o API Gateway invocar a Lambda

Durante a criação da integração foi habilitada a opção:

```text
Conceda permissão ao API Gateway para invocar sua função do Lambda
```

Essa configuração permite que o API Gateway execute a função `cloud-resume-counter` quando uma requisição chegar à rota `GET /count`.

Essa etapa foi necessária porque o API Gateway precisa ter permissão para invocar a função Lambda.

---

### 9.6 Formato da carga

A integração foi configurada utilizando:

```text
Versão do formato da carga:
2.0
```

O formato 2.0 define como a requisição é enviada pelo API Gateway para o Lambda e como a resposta da função é interpretada.

Não foi necessário configurar mapeamentos personalizados.

Configuração:

```text
Mapeamento de parâmetros de solicitação:
Não configurado

Mapeamentos de parâmetros de resposta:
Não configurado
```

---

### 9.7 Tempo limite

A integração permaneceu com o tempo limite padrão:

```text
30000 ms
```

ou:

```text
30 segundos
```

Para uma função simples como a utilizada no projeto, não foi necessário alterar esse valor.

---

### 9.8 Arquitetura da integração

Após a configuração da integração, a arquitetura passou a funcionar desta maneira:

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
│      CloudResumeAPI     │
│        GET /count       │
└────────────┬────────────┘
             │
             │ Invocação
             ▼
┌─────────────────────────┐
│         Lambda          │
│                         │
│   cloud-resume-counter  │
└────────────┬────────────┘
             │
             │ GetItem
             ▼
┌─────────────────────────┐
│        DynamoDB         │
│                         │
│  CloudResumeVisitorCount│
│                         │
│  id: visitor-count      │
│  count: 0               │
└─────────────────────────┘
```

---

### 9.9 Teste da API

Depois de configurar a integração, a API foi testada diretamente pelo navegador.

Foi realizada uma requisição:

```text
GET /count
```

A API retornou:

```json
{
  "count": 0
}
```

Esse resultado confirmou que a requisição conseguiu percorrer todo o fluxo:

```text
Navegador
    ↓
API Gateway
    ↓
Lambda
    ↓
DynamoDB
    ↓
Resposta
```

---

### 9.10 O que aconteceu durante o teste

Quando a rota foi acessada, o navegador enviou uma requisição HTTP:

```text
GET /count
```

O API Gateway recebeu a requisição e identificou a rota correspondente.

Em seguida, o API Gateway invocou a função:

```text
cloud-resume-counter
```

A Lambda executou o código Python e utilizou `boto3` para consultar o DynamoDB.

A função realizou uma operação:

```text
GetItem
```

na tabela:

```text
CloudResumeVisitorCount
```

utilizando a chave:

```text
id = visitor-count
```

O DynamoDB retornou:

```text
count = 0
```

A Lambda então retornou uma resposta HTTP:

```json
{
  "statusCode": 200,
  "body": "{\"count\": 0}"
}
```

O API Gateway processou a resposta e entregou o resultado ao navegador:

```json
{
  "count": 0
}
```

---

### 9.11 Resultado do teste

O teste confirmou que a integração entre os serviços está funcionando corretamente.

Foi validado o seguinte fluxo:

```text
✅ Navegador
       ↓
✅ API Gateway
       ↓
✅ AWS Lambda
       ↓
✅ DynamoDB
```

Também foi confirmado que:

- a rota `GET /count` está funcionando;
- o API Gateway consegue invocar a Lambda;
- a Lambda consegue acessar o DynamoDB;
- a Lambda consegue consultar o item `visitor-count`;
- o DynamoDB retorna o valor armazenado;
- a resposta chega corretamente ao navegador.

---

### 9.12 Estado atual do contador

A API já está funcionando, porém o contador ainda está em sua primeira implementação.

Atualmente, a Lambda apenas consulta o valor existente:

```text
DynamoDB
    ↓
GetItem
    ↓
Ler count
    ↓
Retornar count
```

Por isso, o resultado atual é:

```json
{
  "count": 0
}
```

Ainda será necessário implementar a atualização do contador:

```text
DynamoDB
    ↓
Ler count
    ↓
Incrementar +1
    ↓
Salvar novo valor
    ↓
Retornar novo count
```

O comportamento esperado será:

```text
Primeiro acesso → 1
Segundo acesso  → 2
Terceiro acesso → 3
Quarto acesso   → 4
```

Essa implementação será realizada posteriormente, juntamente com a integração do JavaScript com a API.

---

### Resultado

A API do Cloud Resume Challenge foi criada, configurada, integrada ao Lambda e testada com sucesso.

A comunicação entre os serviços está funcionando:

```text
Frontend
   ↓
API Gateway
   ↓
Lambda
   ↓
DynamoDB
```

O endpoint `GET /count` conseguiu consultar o valor armazenado no DynamoDB e retornar o resultado ao navegador.

### Status

**Concluído ✅**

---

## Etapa 10 — Python

### Objetivo

Criar uma função AWS Lambda utilizando Python para acessar o DynamoDB e retornar a quantidade de visitantes armazenada na tabela.

Nesta etapa também foi configurada a permissão IAM necessária para que a Lambda pudesse consultar o DynamoDB.

### Serviços utilizados

- AWS Lambda
- AWS IAM
- Amazon DynamoDB
- Amazon CloudWatch Logs

### Passo a passo

#### 1. Criar a função Lambda

Acessei o serviço **AWS Lambda** pelo console da AWS.

Selecionei **Criar função** e configurei:

- Nome da função: `cloud-resume-counter`
- Runtime: `Python 3.14`
- Região: `us-east-1`

A função foi criada com uma role de execução própria:

```text
cloud-resume-counter-role-lo5xeumx
```

A AWS também adicionou automaticamente a permissão básica necessária para que a Lambda pudesse enviar logs para o CloudWatch.

---

#### 2. Configurar a permissão IAM para o DynamoDB

A função Lambda precisa acessar a tabela:

```text
CloudResumeVisitorCount
```

Acessei:

```text
IAM → Roles → cloud-resume-counter-role-lo5xeumx
```

Depois selecionei:

```text
Add permissions → Create inline policy
```

Foi criada uma política específica para permitir somente as operações necessárias no DynamoDB.

Política criada:

```text
CloudResumeDynamoDBAccess
```

Configuração utilizada:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["dynamodb:GetItem", "dynamodb:UpdateItem"],
      "Resource": "arn:aws:dynamodb:us-east-1:<ACCOUNT_ID>:table/CloudResumeVisitorCount"
    }
  ]
}
```

A política permite:

- `dynamodb:GetItem` — consultar o contador.
- `dynamodb:UpdateItem` — atualizar o contador posteriormente.

O acesso foi limitado especificamente à tabela `CloudResumeVisitorCount`, seguindo o princípio do menor privilégio.

---

#### 3. Configurar o código Python

Na função Lambda, substituí o código inicial da AWS pelo código Python responsável por acessar o DynamoDB.

O código utiliza a biblioteca `boto3` para comunicação com os serviços AWS.

```python
import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("CloudResumeVisitorCount")


def lambda_handler(event, context):

    response = table.get_item(
        Key={
            "id": "visitor-count"
        }
    )

    item = response.get("Item", {})

    count = item.get("count", 0)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "count": int(count)
        })
    }
```

A função realiza as seguintes operações:

1. Importa `boto3`.
2. Cria uma conexão com o DynamoDB.
3. Seleciona a tabela `CloudResumeVisitorCount`.
4. Consulta o item cujo `id` é `visitor-count`.
5. Obtém o valor armazenado em `count`.
6. Caso o item não seja encontrado, utiliza `0`.
7. Retorna o contador em uma resposta com `statusCode 200`.

---

#### 4. Fazer o deploy da função

Depois de inserir o código Python, selecionei **Deploy** no console da AWS Lambda.

A AWS confirmou que a função foi atualizada com sucesso.

---

#### 5. Criar um evento de teste

Para testar a função diretamente pela Lambda, acessei a aba **Test**.

Criei um novo evento com:

- Tipo de invocação: **Síncrona**
- Nome do evento: `test-counter`
- Compartilhamento: **Privado**
- Modelo: nenhum
- JSON do evento:

```json
{}
```

O evento não precisa enviar informações para a função, pois a própria Lambda sabe qual tabela e qual item do DynamoDB deve consultar.

---

#### 6. Executar o teste

Executei a função através do botão **Testar**.

A execução foi concluída com sucesso.

Resultado retornado:

```json
{
  "statusCode": 200,
  "body": "{\"count\": 0}"
}
```

O resultado confirmou que a Lambda conseguiu acessar o DynamoDB e recuperar corretamente o valor inicial do contador.

### Arquitetura da etapa

```text
AWS Lambda
    │
    │ boto3
    ▼
Amazon DynamoDB
    │
    ▼
CloudResumeVisitorCount
    │
    └── visitor-count
            │
            └── count = 0
```

### Fluxo da execução

```text
Evento de teste {}
       │
       ▼
Lambda cloud-resume-counter
       │
       │ GetItem
       ▼
DynamoDB
       │
       │ count = 0
       ▼
Lambda
       │
       ▼
HTTP 200
       │
       └── {"count": 0}
```

### Resultado

A função Lambda foi criada e configurada com Python 3.14.

A Lambda conseguiu acessar o DynamoDB utilizando `boto3` e as permissões IAM configuradas especificamente para a tabela do projeto.

O teste foi executado com sucesso e retornou:

```json
{
  "statusCode": 200,
  "body": "{\"count\": 0}"
}
```

### Observação

Nesta primeira implementação, a Lambda apenas consulta o contador.

A atualização do valor será utilizada posteriormente para implementar o contador de visitantes completo.

### Status

**Concluído ✅**

---

# Objetivo profissional

Utilizar o projeto como laboratório prático para desenvolver e demonstrar conhecimentos em **Cloud Computing, AWS, infraestrutura, automação, DevOps e CI/CD**.

## Status do projeto

🚧 Projeto em desenvolvimento.

O projeto será atualizado conforme cada etapa do Cloud Resume Challenge for implementada, testada e documentada.
