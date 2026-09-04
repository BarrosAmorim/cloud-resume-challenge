# Etapa 10 — Testes

## Objetivo

Criar testes automatizados para o código Python utilizado na AWS Lambda, verificando se a função retorna os resultados esperados e envia corretamente a operação de incremento para o DynamoDB.

## Ferramentas utilizadas

- Python
- Pytest
- unittest.mock
- MagicMock

## Estrutura

```
cloud-resume-challenge/
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
│
├── backend/
│   ├── lambda_function.py
│   └── test_lambda_function.py
│
└── README.md
```

## Instalação do Pytest

```
pip install pytest
```

Versão instalada: `pytest 9.1.1`. Também foi instalado o `boto3`, necessário para executar localmente o código da Lambda.

## Testes automatizados

Foram criados três testes utilizando `pytest`:

### 1. Teste do retorno da Lambda

Verifica se a Lambda executa corretamente, retorna `statusCode` igual a `200` e retorna o valor esperado do contador.

### 2. Teste do incremento

Verifica se a Lambda envia corretamente a operação de incremento para o DynamoDB (`ADD #count :inc` com `:inc = 1`) e a chave utilizada (`id = visitor-count`).

### 3. Teste com outro valor

Utiliza um segundo cenário com o contador igual a `100`, garantindo que o teste não dependa exclusivamente de um único valor.

## Simulação do DynamoDB

Os testes não utilizam o DynamoDB real — foi utilizado `MagicMock` para simular a resposta, permitindo executar os testes localmente sem alterar o contador real utilizado pelo site.

## Execução dos testes

```
pytest test_lambda_function.py
```

Resultado:

```
3 passed in 0.76s
```

## Resultado

Os três testes foram executados com sucesso, permitindo validar automaticamente o comportamento principal da função Python utilizada pelo contador de visitantes.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
