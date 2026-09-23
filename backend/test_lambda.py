import os
import boto3
import json
import pytest
from moto import mock_aws

# Definir a região simulada para a AWS antes de carregar dependências
os.environ["AWS_DEFAULT_REGION"] = "us-east-1"
os.environ["TABLE_NAME"] = "cloud-resume-visitor-counter"

@pytest.fixture
def dynamodb_mock():
    with mock_aws():
        # Cria a tabela DynamoDB simulada em memória
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        table = dynamodb.create_table(
            TableName="cloud-resume-visitor-counter",
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST"
        )
        yield table

def test_lambda_handler_increments_counter(dynamodb_mock):
    # Importa a função dentro do contexto simulado
    import lambda_function

    # Aponta a tabela do módulo para a tabela simulada do fixture
    lambda_function.table = dynamodb_mock

    # Primeira execução: o contador deve ser 1
    response_1 = lambda_function.lambda_handler({}, None)
    assert response_1["statusCode"] == 200
    body_1 = json.loads(response_1["body"])
    assert body_1["count"] == 1

    # Segunda execução: o contador deve ser incrementado para 2
    response_2 = lambda_function.lambda_handler({}, None)
    assert response_2["statusCode"] == 200
    body_2 = json.loads(response_2["body"])
    assert body_2["count"] == 2

def test_lambda_handler_handles_exception():
    import lambda_function

    # Aponta para um objeto nulo/inválido para forçar a exceção
    lambda_function.table = None

    response = lambda_function.lambda_handler({}, None)

    assert response["statusCode"] == 500
    body = json.loads(response["body"])
    assert "error" in body