# Etapa: Integração Frontend com JavaScript e Consumo da API Serverless

## 1. Objetivo
- Integrar o frontend estático alojado no Amazon S3 e distribuído via Amazon CloudFront à arquitetura serverless de backend.
- Desenvolver um script assíncrono em JavaScript utilizando a Fetch API nativa para comunicar com o endpoint HTTPS gerado pelo Amazon API Gateway v2.
- Atualizar dinamicamente o DOM da página HTML com o número de visitantes retornado pelo banco de dados Amazon DynamoDB.
- Assegurar tratamento adequado de falhas de rede e sincronizar os ficheiros estáticos via AWS CLI.

---


## 2. Implementação no Frontend

Estrutura HTML (frontend/index.html):
<footer>
    <p>Visitantes: <span id="visitor-count">--</span></p>
</footer>

<script src="main.js"></script>

Script JavaScript (frontend/main.js):
const API_URL = "https://bz4vz2bwtb.execute-api.us-east-1.amazonaws.com";

async function updateVisitorCounter() {
    const counterElement = document.getElementById("visitor-count");

    try {
        const response = await fetch(API_URL, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            }
        });

        if (!response.ok) {
            throw new Error(`Erro na resposta da rede: ${response.status}`);
        }

        const data = await response.json();
        counterElement.textContent = data.count;
    } catch (error) {
        console.error("Falha ao carregar o contador de visitas:", error);
        counterElement.textContent = "Erro";
    }
}

document.addEventListener("DOMContentLoaded", updateVisitorCounter);

---

## 3. Implementação e Sincronização com o Amazon S3

Sincronização via AWS CLI:
aws s3 sync frontend/ s3://cloud-resume-challenge-rafael --delete

---

## 4. Validação de Ponta a Ponta

1. Acesso via Navegador Web:
   - O sítio web foi acedido através do domínio distribuído pelo CloudFront.
   - O elemento #visitor-count foi automaticamente atualizado com a contagem persistida no Amazon DynamoDB.

2. Inspeção de Rede (DevTools):
   - Requisição OPTIONS (Preflight CORS): status 200 OK com cabeçalhos de permissão.
   - Requisição POST /: status 200 OK retornando o payload {"count": <novo_valor>}.
   - Atualização atómica incremental verificada a cada recarregamento da página.