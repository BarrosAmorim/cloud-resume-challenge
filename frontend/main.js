const API_URL = "https://2iybyoxh0g.execute-api.us-east-1.amazonaws.com";

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