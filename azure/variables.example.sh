#!/usr/bin/env bash
# ============================================================
# Pet Family API — variáveis de ambiente para os scripts Azure CLI
# ============================================================
# Copie este arquivo para "variables.sh" (mesma pasta) e preencha
# com valores REAIS. "variables.sh" é ignorado pelo git — nunca
# commite segredos.
#
#   cp azure/variables.example.sh azure/variables.sh
#   # edite azure/variables.sh
#   source azure/variables.sh   # ou deixe que cada script faça isso
#
# Todos os valores abaixo são placeholders seguros. Nomes de
# recursos que precisam ser globalmente únicos no Azure (App
# Service, servidor PostgreSQL) já vêm com um sufixo de exemplo —
# troque por algo próprio do seu grupo (ex.: RM + iniciais).
# ============================================================

# --- Identificação do grupo/entrega -------------------------
export RM_GRUPO="rmXXXXXX"                 # ex.: rm566551 — usado para gerar nomes únicos

# --- Recursos Azure -------------------------------------------
export AZURE_RESOURCE_GROUP="rg-petfamily-devops"
export AZURE_LOCATION="brazilsouth"        # troque se o SKU/região não tiver disponibilidade

# App Service
export APP_SERVICE_PLAN="plan-petfamily-${RM_GRUPO}"
export APP_SERVICE_NAME="petfamily-api-${RM_GRUPO}"   # vira https://<nome>.azurewebsites.net
export APP_SERVICE_SKU="B1"                # Basic — adequado para atividade acadêmica

# PostgreSQL Flexible Server
export POSTGRES_SERVER_NAME="petfamily-pg-${RM_GRUPO}" # globalmente único
export POSTGRES_DB_NAME="petfamily"
export POSTGRES_ADMIN_USER="petfamilyadmin"
export POSTGRES_SKU="Standard_B1ms"        # Burstable — menor custo, adequado para acadêmico
export POSTGRES_TIER="Burstable"
export POSTGRES_VERSION="16"
export POSTGRES_STORAGE_GB="32"

# --- Segredos (NÃO preencha valores reais aqui; exporte no shell
#     antes de rodar os scripts, ou digite quando solicitado) ----
# export POSTGRES_ADMIN_PASSWORD=""        # NÃO commitar. Se vazio, o script pede via prompt seguro.
# export JWT_SECRET=""                     # NÃO commitar. Se vazio, o script gera um valor aleatório.

# --- Aplicação ------------------------------------------------
export CORS_ALLOWED_ORIGINS="*"            # troque por domínios reais do app mobile em produção
export JWT_EXPIRATION_MS="86400000"        # 24h

# --- Build/Deploy ----------------------------------------------
export JAR_RELATIVE_PATH="target/petfamily-1.0.0.jar"
