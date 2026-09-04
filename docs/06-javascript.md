# Etapa 6 — JavaScript

## Objetivo

Adicionar JavaScript ao currículo para criar um contador de visitantes.

A implementação utiliza uma API criada no Amazon API Gateway para receber a requisição do frontend. A API aciona uma função AWS Lambda, que consulta e atualiza o contador armazenado no Amazon DynamoDB.

O objetivo é que cada acesso ao currículo incremente o número de visitantes.

## Implementação inicial

Inicialmente, foi utilizado um valor fixo no JavaScript para validar a integração entre o HTML e o JavaScript:

```javascript
const contador = document.getElementById("visitor-count");
contador.textContent = "1";
```

Essa implementação foi utilizada somente durante os testes iniciais.

## Integração com a API

Após a criação do backend, o JavaScript foi atualizado para realizar uma requisição HTTP para o endpoint `/count` da API Gateway.

```javascript
const contador = document.getElementById("visitor-count");

fetch("https://cikqe4oo7h.execute-api.us-east-1.amazonaws.com/count")
  .then((response) => response.json())
  .then((data) => {
    contador.textContent = data.count;
  })
  .catch((error) => {
    console.error("Erro ao buscar contador:", error);
    contador.textContent = "0";
  });
```

O JavaScript utiliza `fetch()` para consultar a API e recebe como resposta o número atual de visitantes.

## Configuração do CORS

Como o frontend e a API estão em origens diferentes, foi necessário configurar o CORS no Amazon API Gateway.

Foi permitido o acesso da origem `https://barrosamorimd.work`, com o método `GET`.

Essa configuração permite que o JavaScript executado no currículo faça requisições para a API Gateway.

## Publicação do frontend

Após a alteração do JavaScript, os arquivos do frontend foram atualizados no bucket Amazon S3:

```
frontend/
├── index.html
├── style.css
└── script.js
```

Em seguida, foi realizada uma invalidação do cache do Amazon CloudFront (`/*`), garantindo que o CloudFront disponibilizasse a versão atualizada do frontend.

## Arquitetura

```
Usuário
   │
   │ HTTPS
   ▼
barrosamorimd.work
   │
   │ JavaScript / fetch()
   ▼
Amazon API Gateway
   │
   │ GET /count
   ▼
AWS Lambda
   │
   │ UpdateItem
   ▼
Amazon DynamoDB
   │
   │ contador
   ▼
Novo número de visitantes
```

## Fluxo completo

Quando um usuário acessa o currículo:

1. O navegador carrega o `index.html`.
2. O `script.js` é executado.
3. O JavaScript realiza uma requisição `GET` para a API Gateway.
4. O API Gateway invoca a função Lambda.
5. A Lambda atualiza o contador no DynamoDB.
6. O novo valor é retornado pela API.
7. O JavaScript atualiza o elemento `visitor-count` no HTML.
8. O número atualizado é exibido no currículo.

## Validação

A implementação foi testada através do domínio público `https://barrosamorimd.work`.

O contador inicialmente apresentou `Visitantes: 50`. Após atualizar a página, o contador foi incrementado para `Visitantes: 51`.

Esse comportamento confirmou que o contador está sendo atualizado dinamicamente e que a integração entre frontend, API Gateway, Lambda e DynamoDB está funcionando em produção.

## Resultado

O currículo agora possui um contador de visitantes funcional. O JavaScript deixou de utilizar um valor fixo e passou a consumir dados reais da infraestrutura AWS.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
