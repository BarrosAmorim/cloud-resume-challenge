# Etapa 7 — Banco de dados (DynamoDB)

## Objetivo

Criar um banco de dados para armazenar a quantidade de visitantes do currículo, utilizando o Amazon DynamoDB em modo de capacidade sob demanda.

## Serviço utilizado

- Amazon DynamoDB

## Passo a passo

1. Acessei o serviço Amazon DynamoDB através do console da AWS.
2. Selecionei a opção para criar uma nova tabela.
3. Criei a tabela com o nome `CloudResumeVisitorCount`.
4. Configurei a chave de partição da tabela como `id`.
5. Defini o tipo da chave de partição como `String`.
6. Não utilizei chave de classificação, pois o projeto necessita apenas de um registro para armazenar a contagem de visitantes.
7. Mantive a classe da tabela como **DynamoDB Standard**.
8. Configurei o modo de capacidade como **Sob demanda (On-Demand)**.
9. Mantive as configurações padrão de criptografia utilizando uma chave de propriedade da AWS.
10. Adicionei uma tag para identificar o recurso: `Project = CloudResumeChallenge`.
11. Criei a tabela e aguardei até que seu status fosse alterado para **Ativa**.
12. Acessei a opção de exploração dos itens da tabela.
13. Criei o primeiro item para armazenar a contagem de visitantes.
14. Configurei a chave de partição do item como `id = "visitor-count"`.
15. Adicionei o atributo responsável pela quantidade de visitantes: `count = 0`.

## Estrutura da tabela

```
CloudResumeVisitorCount

┌────────────────┬───────┐
│ id             │ count │
├────────────────┼───────┤
│ visitor-count  │   0   │
└────────────────┴───────┘
```

## Resultado

Foi criada uma tabela DynamoDB em modo de capacidade sob demanda para armazenar a quantidade de visitantes do currículo.

O item inicial foi criado com a contagem `0`, preparando o banco de dados para que a aplicação possa consultar e atualizar esse valor através de uma API.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
