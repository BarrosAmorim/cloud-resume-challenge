# Etapa 03: CSS

## 1. Objetivo
- Aplicar estilo visual profissional, limpo e legível ao currículo HTML.
- Garantir responsividade básica para que o conteúdo se adapte tanto a desktops quanto a dispositivos móveis.

## 2. Conceitos e Decisões Técnicas
- **Box Sizing Global:** Configuração de `box-sizing: border-box` no seletor universal para padronizar o modelo de caixas e simplificar o cálculo de espaçamentos.
- **Layout Responsivo:**
  - **Laboratório:** Usar larguras fixas em pixels (`width: 900px`), forçando barras de rolagem horizontais em telas menores como celulares.
  - **Boa prática:** Utilizar limite máximo de largura (`max-width: 800px`) com margem automática e preenchimento lateral percentual/relativo, garantindo adaptação natural a qualquer resolução sem quebras de layout.
- **Unidades Relativas:** Uso de `rem` para tipografia hierárquica, facilitando escalabilidade e acessibilidade.

## 3. Estado Atual da Arquitetura
```text
[ Arquivos Locais ]
       |
       +---> index.html (Estrutura semântica)
       |
       +---> style.css  (Apresentação visual responsiva)