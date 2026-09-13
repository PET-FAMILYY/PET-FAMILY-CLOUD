#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib-common.sh"

load_variables
require_azure_cli
require_env AZURE_RESOURCE_GROUP POSTGRES_SERVER_NAME POSTGRES_DB_NAME POSTGRES_ADMIN_USER

command -v psql >/dev/null 2>&1 || fail "psql não encontrado no PATH. Instale o cliente PostgreSQL:
  - Windows: https://www.postgresql.org/download/windows/ (ou 'winget install PostgreSQL.PostgreSQL')
  - macOS:   brew install libpq && brew link --force libpq
  - Linux:   sudo apt-get install postgresql-client"

prompt_secret_if_missing POSTGRES_ADMIN_PASSWORD "Senha do administrador do PostgreSQL"
require_env POSTGRES_ADMIN_PASSWORD

MY_IP="$(curl -s --max-time 5 https://api.ipify.org || echo "")"
if [ -n "$MY_IP" ]; then
    log "Garantindo que o IP atual ($MY_IP) está liberado no firewall do servidor..."
    az postgres flexible-server firewall-rule create \
        --resource-group "$AZURE_RESOURCE_GROUP" \
        --name "$POSTGRES_SERVER_NAME" \
        --rule-name "AllowClientAtual" \
        --start-ip-address "$MY_IP" \
        --end-ip-address "$MY_IP" \
        --output none 2>/dev/null || true
else
    warn "Não foi possível detectar o IP público atual — se a conexão falhar, libere manualmente com 'az postgres flexible-server firewall-rule create'."
fi

HOST="${POSTGRES_SERVER_NAME}.postgres.database.azure.com"
export PGPASSWORD="$POSTGRES_ADMIN_PASSWORD"

if [ "$#" -ge 1 ]; then
    SQL_FILE="$1"
    [ -f "$SQL_FILE" ] || fail "Arquivo '$SQL_FILE' não encontrado."

    PSQL_VARS=()
    if [ "$(basename "$SQL_FILE")" = "seed-veterinario.sql" ]; then
        prompt_secret_if_missing VET_SEED_PASSWORD "Senha para a conta de veterinário demo (mín. 8 caracteres)"
        require_env VET_SEED_PASSWORD
        PSQL_VARS=(-v "vet_password=${VET_SEED_PASSWORD}")
    fi

    log "Executando '$SQL_FILE' contra $POSTGRES_DB_NAME em $HOST..."
    psql "${PSQL_VARS[@]}" -f "$SQL_FILE" \
        "host=$HOST port=5432 dbname=$POSTGRES_DB_NAME user=$POSTGRES_ADMIN_USER sslmode=require"
else
    log "Abrindo sessão psql interativa em $POSTGRES_DB_NAME @ $HOST (SSL obrigatório)..."
    psql "host=$HOST port=5432 dbname=$POSTGRES_DB_NAME user=$POSTGRES_ADMIN_USER sslmode=require"
fi

unset PGPASSWORD
