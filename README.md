# 🛡️ n8n Incident Response - Agente Autônomo de SRE
Este projeto implementa um Agente de SRE (Site Reliability Engineering) Autônomo capaz de triar, analisar e remediar incidentes de infraestrutura sem intervenção humana inicial.

Diferente de automações baseadas em regras rígidas (ex: if cpu > 90%), este agente utiliza IA Generativa (LLM) para interpretar logs técnicos, correlacionar eventos com mudanças de código (GitHub) e tomar decisões baseadas em contexto semântico.

## 🎯 O Problema
Em ambientes de alta escala, o "Alert Fatigue" (Fadiga de Alertas) faz com que engenheiros ignorem avisos críticos. Além disso, incidentes simples (como reiniciar um serviço travado) consomem tempo valioso, e alertas de segurança podem se perder no meio de logs de performance.

## 💡 A Solução Inteligente
Um pipeline orquestrado no n8n que ingere alertas, enriquece os dados com contexto de deploy e decide a ação correta:

*   **Infraestrutura (Self-Healing):** Se a IA detecta travamento de SO/Hardware (ex: Memory Leak, Zumbi Process), aciona script de Restart via SSH.
*   **Engenharia de Software:** Se a IA correlaciona o erro com um deploy recente (Commit no GitHub) ou falha lógica, abre um Bug Report no Jira.
*   **Crítico/Segurança (Escalation):** Se a IA detecta riscos de negócio (ex: Ransomware, SQL Injection, Vazamento de Dados), ignora automações e Escalona para Humanos via Gmail imediatamente.

> **Nota:** No estado atual, as ações de `BUG_REPORT` (Jira) e `RESTART` (SSH) são representadas por nós de simulação no workflow. A lógica de decisão está completa, e estes nós podem ser substituídos por integrações reais do n8n com Jira e SSH para um ambiente de produção.

## 🛠️ Tech Stack & Arquitetura
*   **Orquestração:** n8n (Self-hosted via Docker).
*   **IA Engine:** Groq API (Llama-3-70b / Mixtral) para análise cognitiva.
*   **Containerização:** Docker & Docker Compose.
*   **Scripting:** JavaScript (dentro do n8n) para estruturação de Prompts Avançados.
*   **Banco de Dados:** PostgreSQL (Log de auditoria de incidentes).
*   **Integrações:** 
    *   GitHub API: Para verificar "Change Management" (quem mexeu no código?).
    *   Gmail (OAuth2): Para alertas críticos.

## ⚙️ Diferencial Técnico (Context Awareness)
O agente foi treinado (via Prompt Engineering) para evitar "Falsos Positivos" e entender nuances:

**Exemplo:** Se a memória está cheia, mas houve um deploy recente, um bot comum culparia o deploy. Este agente analisa se o erro é "físico" (vazamento de memória gradual) ou "lógico" (loop infinito no código novo) antes de tomar a decisão.

## 🚀 Como Rodar Localmente
### Pré-requisitos
*   Docker e Docker Compose instalados.
*   Chave de API da Groq (Grátis).
*   Credenciais do Gmail (Opcional para envio de e-mail).

### Passo a passo
1.  Clone o repositório:
    ```bash
    git clone https://github.com/lzMichelotti/n8n-incident-response.git
    cd n8n-incident-response
    ```
2.  Configure as Variáveis (.env): Crie um arquivo .env na raiz:
    ```
    POSTGRES_USER=n8nuser
    POSTGRES_PASSWORD=n8npassword
    POSTGRES_DB=incidents
    ```
3.  Suba a Stack:
    ```bash
    docker compose up -d
    ```
4.  Importe o Workflow:
    *   Acesse http://localhost:5678.
    *   Importe o arquivo `main_workflow.json`.
    *   Configure as credenciais (Groq, Postgres, Gmail) nos respectivos nós.

## 🧪 Simulando Incidentes (Testes)
Você pode simular os alertas enviando payloads via curl para o Webhook do n8n.

### Cenário Realista: Ataque de Segurança (Dispara Gmail) 📧
Este payload simula um alerta vindo de um WAF (Web Application Firewall) indicando exfiltração de dados via SQL Injection.

```bash
curl -X POST http://localhost:5678/webhook-test/sre-alert \
-H "Content-Type: application/json" \
-d 
{
  "alert_name": "WAF Critical: SQL Injection Detected",
  "server": "payment-gateway-prod-02",
  "severity": "critical",
  "description": "ModSecurity WAF detected a SQL Injection attempt on endpoint /api/v1/checkout. Payload contains UNION SELECT sensitive_data. Outbound traffic to suspicious IP 192.168.x.x increased by 500% in the last 2 minutes. Immediate blockage required."
}
```
**Comportamento Esperado:**
*   A IA analisará que reiniciar o servidor não resolve (o ataque continua).
*   A IA verá que não é um bug de código simples, mas um ataque ativo.
*   O sistema classificará como CRITICAL/HUMANO e enviará um e-mail urgente para o administrador.

Desenvolvido por Lorenzo Michelotti