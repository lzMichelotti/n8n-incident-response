# 🛡️ n8n Incident Response - Agente Autônomo de SRE & Resposta a Incidentes

> **Status:** Concluído ✅

Este projeto simula um Agente de SRE (Site Reliability Engineering) automatizado, desenvolvido para orchestrar a triagem e resposta a incidentes de infraestrutura sem intervenção humana inicial.

## 🎯 O Problema
Em ambientes de alta escala, alertas de monitoramento geram ruído excessivo ("alert fatigue"). SREs perdem tempo triando incidentes repetitivos em vez de focar em engenharia.

## 💡 A Solução: n8n Incident Response
Um pipeline inteligente que ingere alertas, usa **IA Generativa (LLM)** para analisar a correlação entre métricas e mudanças recentes (Commits), e decide autonomamente entre:
1.  **Reiniciar serviço** (Self-healing).
2.  **Abrir Bug Report** (Se a causa for código novo).
3.  **Escalar para Humano** (Apenas em casos críticos reais).

## 🛠️ Tech Stack
* **Orquestração:** [n8n](https://n8n.io/) (Workflow Automation)
* **IA & Lógica:** Python + Groq API (LLM Llama-3/Mixtral)
* **Infraestrutura:** Docker & Docker Compose
* **Banco de Dados:** PostgreSQL (Persistência de Logs de Incidentes)
* **Integrações:** GitHub API (Investigação de Commits), Webhooks.

## ⚙️ Arquitetura da Solução
1.  **Ingestão:** Webhook recebe payload JSON (Simulando Prometheus/Grafana).
2.  **Enriquecimento:** O sistema consulta a API do GitHub para verificar se houve deploys recentes.
3.  **Análise Cognitiva:** Um script Python normaliza os dados e envia para o LLM com um Prompt de SRE Sênior.
4.  **Decisão & Ação:**
    * `RESTART`: Se memória > 90% e sem deploys recentes.
    * `BUG_REPORT`: Se houver commits recentes coincidindo com o erro.
    * `ESCALATE`: Se detectado padrão crítico (ex: Deadlocks recorrentes).
5.  **Auditoria:** Todos os passos são gravados no PostgreSQL.

## 🚀 Como Rodar Localmente

### Pré-requisitos
* Docker e Docker Compose instalados.
* Uma chave de API da Groq (Grátis).

### Passo a passo
1.  Clone o repositório:
    ```bash
    git clone https://github.com/lzMichelotti/n8n-incident-response.git
    cd n8n-incident-response
    ```
2.  Crie o arquivo de variáveis de ambiente `.env`:
    Crie um arquivo chamado `.env` na raiz do projeto (no mesmo nível de `docker-compose.yml`) com o seguinte conteúdo para as credenciais do PostgreSQL:
    ```
    POSTGRES_USER=n8nuser
    POSTGRES_PASSWORD=n8npassword
    POSTGRES_DB=incidents
    ```
3.  Suba a stack (O banco de dados será criado automaticamente):
    ```bash
    docker compose up -d
    ```
4.  Acesse o n8n e importe o workflow:
    *   Aguarde alguns instantes para os serviços inicializarem.
    *   Acesse o n8n em: `http://localhost:5678`
    *   Vá em "Workflows" > "Import from File".
    *   Selecione o arquivo `workflows/main_workflow.json`.
5.  Configure suas credenciais no n8n:
    Após importar o workflow, você precisará configurar as credenciais para o Groq, PostgreSQL e (opcionalmente) Gmail:
    *   **Groq (Nó "Groq Chat Model"):**
        *   Obtenha sua chave de API gratuita no site da [Groq](https://groq.com/).
        *   No nó "Groq Chat Model" do workflow, clique para adicionar uma nova credencial.
        *   Cole sua chave de API Groq.
    *   **PostgreSQL (Nós "Postgres" e "Postgres1"):**
        *   Nos nós "Postgres" e "Postgres1", adicione uma nova credencial.
        *   Use os seguintes dados (conforme definidos no seu arquivo `.env`):
            *   **User:** `n8nuser`
            *   **Password:** `n8npassword`
            *   **Database:** `incidents`
            *   **Host:** `postgres-db` (este é o nome do serviço no Docker Compose)
            *   **Port:** `5432`
    *   **Gmail (Nó "Gmail" - Opcional):**
        *   Se você pretende usar a funcionalidade de escalonamento por e-mail, configure as credenciais do Gmail no nó "Gmail" do workflow.

## 🧠 Aprendizados Chave
Este projeto consolidou conhecimentos em:
* Arquitetura orientada a eventos.
* Prompt Engineering para tomadas de decisão técnicas.
* Manipulação de dados JSON com Python.
* Infraestrutura como Código (IaC) com Docker.

---
Desenvolvido por Lorenzo Michelotti Palma (https://www.linkedin.com/in/lorenzo-michelotti-palma/)
