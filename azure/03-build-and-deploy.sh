#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/lib-common.sh"

load_variables
require_azure_cli
require_env AZURE_RESOURCE_GROUP APP_SERVICE_NAME JAR_RELATIVE_PATH

log "Verificando pré-requisitos..."
command -v mvn >/dev/null 2>&1 || fail "Maven ('mvn') não encontrado no PATH e nenhum Maven Wrapper disponível."

cd "$PROJECT_ROOT"

MAVEN_CMD="mvn"
if [ -f "./mvnw" ]; then
    MAVEN_CMD="./mvnw"
    chmod +x ./mvnw || true
    log "Usando Maven Wrapper (./mvnw)."
else
    warn "Maven Wrapper não encontrado — usando 'mvn' do PATH."
fi

log "Rodando testes automatizados (perfil 'test', H2 isolado)..."
"$MAVEN_CMD" -q clean test

log "Gerando o JAR (mvn package)..."
"$MAVEN_CMD" -q package -DskipTests

if [ ! -f "$JAR_RELATIVE_PATH" ]; then
    FOUND_JAR="$(find target -maxdepth 1 -name "*.jar" ! -name "*sources*" ! -name "*javadoc*" | head -n1)"
    if [ -z "$FOUND_JAR" ]; then
        fail "JAR não encontrado em '$JAR_RELATIVE_PATH' nem em target/. Confira o build."
    fi
    warn "JAR não estava em '$JAR_RELATIVE_PATH'; usando '$FOUND_JAR'."
    JAR_RELATIVE_PATH="$FOUND_JAR"
fi

log "JAR pronto: $JAR_RELATIVE_PATH ($(du -h "$JAR_RELATIVE_PATH" | cut -f1))"

log "Publicando no App Service '$APP_SERVICE_NAME' (az webapp deploy)..."
az webapp deploy \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$APP_SERVICE_NAME" \
    --src-path "$JAR_RELATIVE_PATH" \
    --type jar \
    --output none

APP_URL="https://${APP_SERVICE_NAME}.azurewebsites.net"
log "Deploy publicado. Aguardando a aplicação subir..."

log "URL pública: $APP_URL"

SUCCESS=0
for attempt in $(seq 1 12); do
    sleep 10
    STATUS_CODE="$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${APP_URL}/actuator/health" || echo "000")"
    if [ "$STATUS_CODE" = "200" ]; then
        log "Health check OK (HTTP 200) em ${APP_URL}/actuator/health — tentativa $attempt."
        SUCCESS=1
        break
    fi
    log "Tentativa $attempt/12: health check respondeu HTTP $STATUS_CODE, aguardando..."
done

if [ "$SUCCESS" -eq 0 ]; then
    warn "A aplicação não respondeu 200 em ${APP_URL}/actuator/health dentro do tempo esperado."
    warn "Isso é comum no primeiro deploy (cold start / migrations do Flyway rodando)."
    warn "Consulte os logs em tempo real com:"
    echo "    az webapp log tail --resource-group $AZURE_RESOURCE_GROUP --name $APP_SERVICE_NAME"
    warn "Ou baixe o log completo com:"
    echo "    az webapp log download --resource-group $AZURE_RESOURCE_GROUP --name $APP_SERVICE_NAME --log-file webapp-log.zip"
else
    log "Swagger UI: ${APP_URL}/swagger-ui.html"
fi

log "Deploy finalizado."
