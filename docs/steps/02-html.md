# Etapa 02: HTML

## 1. Objetivo
- Estruturar o conteúdo do meu currículo profissional em HTML5 semântico.
- Preparar o ponto de injeção dinâmica no DOM para exibir a contagem de acessos que virá da API serverless nas etapas futuras.

## 2. Conceitos e Decisões Técnicas
- **HTML5 Semântico:** Utilização de tags estruturais (`<header>`, `<main>`, `<section>`, `<article>`, `<footer>`) em vez de divisões genéricas sem significado (`<div>`), garantindo melhor acessibilidade, indexação e legibilidade.
- **Separação de Responsabilidades:** Manter o HTML estritamente focado no conteúdo e na estrutura dos dados, sem estilos visuais inline ou lógica de script acoplada.
- **Preparação para Integração Dinâmica:**
  - **Laboratório:** Deixar o número de visitas estático no texto ou sem um identificador único, exigindo manipulação bruta do texto da página.
  - **Boa prática:** Inclusão de uma tag dedicada com identificador único (`<span id="visitor-count">--</span>`), permitindo que o JavaScript atualize exclusivamente o valor numérico de forma assíncrona e cirúrgica.

## 3. Estado Atual da Arquitetura
```text
[ Arquivos Locais ]
       |
       +---> index.html (Estrutura semântica + ponto de injeção DOM)