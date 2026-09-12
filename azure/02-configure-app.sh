#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib-common.sh"

load_variables
require_azure_cli
require_env AZURE_RESOURCE_GROUP APP_SERVICE_NAME \
    POSTGRES_SERVER_NAME POSTGRES_DB_NAME POSTGRES_ADMIN_USER \
    CORS_ALLOWED_ORIGINS JWT_EXPIRATION_MS

prompt_secret_if_missing POSTGRES_ADMIN_PASSWORD "Senha do administrador do PostgreSQL"
require_env POSTGRES_ADMIN_PASSWORD

if [ -z "${JWT_SECRET:-}" ]; then
    log "JWT_SECRET não definido — gerando um segredo aleatório de 64 bytes."
    JWT_SECRET="$(openssl rand -base64 48 2>/dev/null || python -c 'import secrets;print(secrets.token_urlsafe(48))')"
fi
require_env JWT_SECRET

JDBC_URL="jdbc:postgresql://${POSTGRES_SERVER_NAME}.postgres.database.azure.com:5432/${POSTGRES_DB_NAME}?sslmode=require"

log "Aplicando variáveis de ambiente no App Service (valores sensíveis não são exibidos no terminal)..."
az webapp config appsettings set \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$APP_SERVICE_NAME" \
    --settings \
        SPRING_PROFILES_ACTIVE="prod" \
        SPRING_DATASOURCE_URL="$JDBC_URL" \
        SPRING_DATASOURCE_USERNAME="$POSTGRES_ADMIN_USER" \
        SPRING_DATASOURCE_PASSWORD="$POSTGRES_ADMIN_PASSWORD" \
        JWT_SECRET="$JWT_SECRET" \
        JWT_EXPIRATION_MS="$JWT_EXPIRATION_MS" \
        CORS_ALLOWED_ORIGINS="$CORS_ALLOWED_ORIGINS" \
        WEBSITES_PORT="8080" \
    --output none >/dev/null

log "Configurando health check (endpoint público /actuator/health)..."
az webapp config set \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$APP_SERVICE_NAME" \
    --health-check-path "/actuator/health" \
    --output none

log "Habilitando HTTPS-only e always-on..."
az webapp update \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$APP_SERVICE_NAME" \
    --https-only true \
    --output none

az webapp config set \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$APP_SERVICE_NAME" \
    --always-on true \
    --output none 2>/dev/null || warn "always-on não disponível neste SKU — ok em SKUs Free/Shared, mas B1 deveria suportar."

log "App Service configurado."
log "Próximo passo: ./azure/03-build-and-deploy.sh"
