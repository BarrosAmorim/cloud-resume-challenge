# Etapa 8 — API (Amazon API Gateway)

## Objetivo

Criar uma API para permitir que o currículo se comunique com o backend da aplicação.

De acordo com o Cloud Resume Challenge, o JavaScript do currículo não deve acessar diretamente o DynamoDB. A comunicação deve ser realizada através de uma API utilizando o Amazon API Gateway e uma função AWS Lambda.

## Arquitetura

```
Navegador
    │
    │ JavaScript
    │ GET /count
    ▼
Amazon API Gateway
    │
    │ Invoca
    ▼
AWS Lambda
    │
    │ UpdateItem
    ▼
Amazon DynamoDB
    │
    ▼
CloudResumeVisitorCount
```

## Serviços utilizados

- Amazon API Gateway
- AWS Lambda
- Amazon DynamoDB

## Criação do Amazon API Gateway

Acessei o serviço **Amazon API Gateway** através do console da AWS e criei uma nova API.

Configurações utilizadas:

```
Nome: CloudResumeAPI
Tipo: HTTP API
Região: us-east-1
Endereço IP: IPv4
```

Foi escolhido o tipo **HTTP API**, adequado para a comunicação simples necessária neste projeto.

## Configuração do estágio

A API utiliza o estágio padrão `$default`, com a opção de implantação automática habilitada. Com essa configuração, alterações realizadas na API são automaticamente implantadas no estágio `$default`.

## Criação da rota

```
Método HTTP: GET
Caminho: /count
```

O objetivo dessa rota é permitir que o frontend solicite o contador de visitantes.

## Criação da integração com Lambda

A integração foi configurada utilizando:

```
Tipo de integração: Função do Lambda
Região: us-east-1
Função do Lambda: cloud-resume-counter
```

## Permissão para o API Gateway invocar a Lambda

Durante a criação da integração foi habilitada a opção "Conceda permissão ao API Gateway para invocar sua função do Lambda", necessária para que o API Gateway execute a função quando uma requisição chegar à rota `GET /count`.

## Formato da carga

Versão do formato da carga: `2.0`. Não foi necessário configurar mapeamentos personalizados de solicitação ou resposta.

## Tempo limite

A integração permaneceu com o tempo limite configurado em 30 segundos (30000 ms), suficiente para uma função simples como a utilizada no projeto.

## Configuração do CORS

Como o frontend e a API estão hospedados em origens diferentes, foi permitida a origem `https://barrosamorimd.work` com o método `GET`.

## Teste inicial da API

Na primeira implementação, a Lambda apenas consultava o valor armazenado no DynamoDB. O resultado inicial foi:

```json
{ "count": 0 }
```

## Evolução da API para incrementar o contador

Após validar a comunicação entre os serviços, a função Lambda foi atualizada para realizar também a atualização do contador, utilizando a operação `UpdateItem`. O contador passou a ser incrementado em `+1` a cada requisição recebida.

## Fluxo completo

Quando um visitante acessa o currículo:

1. O navegador carrega o `index.html`.
2. O `script.js` é executado.
3. O JavaScript realiza uma requisição `GET /count`.
4. O API Gateway recebe a requisição e invoca a função `cloud-resume-counter`.
5. A Lambda utiliza `boto3` para acessar o DynamoDB.
6. O DynamoDB incrementa o atributo `count`.
7. A Lambda recebe o novo valor e retorna via API.
8. O JavaScript atualiza o elemento `visitor-count` no currículo.

## Resultado

A API do Cloud Resume Challenge foi criada, configurada, integrada ao Lambda e testada com sucesso, com o incremento do contador validado em produção.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
