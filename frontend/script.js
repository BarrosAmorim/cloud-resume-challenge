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
