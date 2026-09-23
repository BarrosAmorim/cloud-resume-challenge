# Step 13: Controle de Versão (Source Control)

## 1. Visão Geral
Em alinhamento com os princípios modernos de engenharia de software e DevOps, o controle de versão com **Git** e **GitHub** foi integrado ao projeto desde o primeiro estágio de desenvolvimento. Toda a base de código — englobando infraestrutura (IaC), backend, frontend e documentação — é versionada de forma centralizada e estruturada para viabilizar automação contínua (CI/CD).

---

## 2. Estratégia de Repositório (Monorepo Estruturado)

Em vez de dispersar o projeto em múltiplos repositórios independentes, foi adotada a abordagem de **Monorepo com separação modular de domínios**. Isso simplifica a governança, garante rastreabilidade total entre infraestrutura e código de aplicação, e viabiliza pipelines de CI/CD orientadas a caminhos de arquivos (*path-based triggers*).

* `terraform/`: Código declarativo de infraestrutura (HCL).
* `backend/`: Código da função Lambda, suíte de testes unitários e dependências.
* `frontend/`: Aplicação web estática (HTML5, CSS3, JavaScript assíncrono).
* `docs/steps/`: Registro técnico cronológico e arquitetural de cada etapa do desafio.

---

## 3. Boas Práticas Implementadas

### 3.1. Convenção Semântica de Commits
O histórico de commits segue o padrão de **Conventional Commits**, facilitando a leitura do log e a geração de changelogs:
* `feat`: Introdução de novas funcionalidades ou componentes de infraestrutura.
* `test`: Criação e refatoração de testes unitários e fixtures.
* `chore`: Ajustes de dependências, `.gitignore` ou configurações gerais.
* `docs`: Adição ou atualização de documentação técnica.

### 3.2. Segurança e Higiene do Repositório (`.gitignore`)
Para evitar vazamento acidental de segredos, chaves de API, credenciais AWS ou artefatos transitórios de compilação, o arquivo `.gitignore` foi configurado rigorosamente na raiz do projeto:
* **Terraform:** Exclusão de pastas locais (`.terraform/`), arquivos de estado (`*.tfstate`, `*.tfstate.backup`) e variáveis locais (`*.tfvars`).
* **Compilação e Artefatos:** Bloqueio de empacotamentos intermediários (`*.zip`).
* **Python:** Ignorados ambientes virtuais (`venv/`, `.venv/`), caches de execução (`__pycache__/`) e caches de teste (`.pytest_cache/`).

---

## 4. Comandos e Verificações de Rotina

```bash
# Verificar status das alterações locais
git status

# Visualizar o histórico formatado de commits semânticos
git log --oneline --graph --decorate -n 10

# Sincronização segura com o repositório remoto
git push origin main