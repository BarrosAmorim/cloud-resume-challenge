# Step 11: Backend Tests (Pytest & Moto)

## 1. Visão Geral
Implementação da suíte de testes unitários automatizados para a função Lambda do contador de visitas (`lambda_function.py`). O objetivo é garantir a validação da lógica de incremento atômico, a formatação das respostas com cabeçalhos CORS e a resiliência no tratamento de exceções, executando de forma totalmente isolada em memória sem necessidade de comunicação com a AWS real.

---

## 2. Tecnologias e Ferramentas

* **Python 3.13 / `venv`:** Ambiente virtual isolado configurado localmente no Raspberry Pi para isolamento das dependências.
* **`pytest` (>= 8.0.0):** Framework de testes responsável pela descoberta, execução e asserção dos testes automatizados.
* **`moto[dynamodb]` (>= 5.0.0):** Biblioteca de mocking que intercepta as chamadas do `boto3` e emula o serviço DynamoDB integralmente em memória RAM.
* **`boto3` (>= 1.34.0):** SDK oficial da AWS utilizado tanto pela função como pelos fixtures de teste para interagir com o DynamoDB.

---

## 3. Arquitetura e Estratégia de Teste

Para viabilizar a execução de testes rápidos, repetíveis e sem custos:
1. Variáveis de ambiente fictícias (`AWS_DEFAULT_REGION="us-east-1"`, `TABLE_NAME="cloud-resume-visitor-counter"`) são injetadas antes do carregamento da aplicação.
2. É criado um fixture de teste via `@pytest.fixture` gerenciado pelo context manager `mock_aws()` do Moto, instanciando uma tabela DynamoDB em memória com chave primária (`id` do tipo String).
3. A instância `lambda_function.table` é apontada diretamente para a tabela mockada em memória antes da invocação do handler.

```text
┌─────────────────┐       ┌───────────────────────┐       ┌────────────────────────┐
│  Pytest Runner  │ ----> │ lambda_handler(event) │ ----> │  Moto DynamoDB Mock    │
└─────────────────┘       └───────────────────────┘       │      (em memória)      │
                                                          └────────────────────────┘
```

---

## 4. Ficheiro de Requisitos (`backend/requirements-dev.txt`)

```text
boto3>=1.34.0
pytest>=8.0.0
moto[dynamodb]>=5.0.0
```

---

## 5. Código dos Testes Unitários (`backend/test_lambda.py`)

```python
import os
import boto3
import json
import pytest
from moto import mock_aws

# Configuração prévia do ambiente para simulação local
os.environ["AWS_DEFAULT_REGION"] = "us-east-1"
os.environ["TABLE_NAME"] = "cloud-resume-visitor-counter"

@pytest.fixture
def dynamodb_mock():
    """Fixture que provisiona uma tabela DynamoDB temporária em memória."""
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        table = dynamodb.create_table(
            TableName="cloud-resume-visitor-counter",
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST"
        )
        yield table

def test_lambda_handler_increments_counter(dynamodb_mock):
    """Valida a inicialização e o incremento sequencial atômico do contador."""
    import lambda_function
    lambda_function.table = dynamodb_mock

    # Primeira execução: o contador deve ser inicializado em 1
    response_1 = lambda_function.lambda_handler({}, None)
    assert response_1["statusCode"] == 200
    assert "Access-Control-Allow-Origin" in response_1["headers"]
    body_1 = json.loads(response_1["body"])
    assert body_1["count"] == 1

    # Segunda execução: o contador deve sofrer incremento atômico para 2
    response_2 = lambda_function.lambda_handler({}, None)
    assert response_2["statusCode"] == 200
    body_2 = json.loads(response_2["body"])
    assert body_2["count"] == 2

def test_lambda_handler_handles_exception():
    """Valida se a função trata falhas e retorna status HTTP 500 com corpo JSON adequado."""
    import lambda_function
    # Simula indisponibilidade/falha forçando a tabela para None
    lambda_function.table = None

    response = lambda_function.lambda_handler({}, None)
    assert response["statusCode"] == 500
    assert "Access-Control-Allow-Origin" in response["headers"]
    body = json.loads(response["body"])
    assert "error" in body
```

---

## 6. Procedimentos de Execução Local

```bash
# 1. Aceder ao diretório do backend
cd ~/projects/cloud-resume-challenge/backend

# 2. Criar e ativar o ambiente virtual isolado
python3 -m venv venv
source venv/bin/activate

# 3. Instalar as dependências de desenvolvimento e teste
pip install -r requirements-dev.txt

# 4. Executar os testes unitários de forma detalhada
pytest -v

# 5. Desativar o ambiente virtual após a execução
deactivate
```

---

## 7. Resultado da Validação

```text
============================= test session starts ==============================
platform linux -- Python 3.13.5, pytest-9.1.1, pluggy-1.6.0
rootdir: /home/rafael/projects/cloud-resume-challenge/backend
cachedir: .pytest_cache
collected 2 items

test_lambda.py::test_lambda_handler_increments_counter PASSED            [ 50%]
test_lambda.py::test_lambda_handler_handles_exception PASSED             [100%]

============================== 2 passed in 0.54s ===============================
```