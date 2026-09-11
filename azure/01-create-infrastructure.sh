#!/usr/bin/env bash
# ============================================================
# Pet Family API — 01: criação da infraestrutura Azure
# ============================================================
# Cria, exclusivamente via Azure CLI (Opção 2 — sem containers):
#   - Resource Group
#   - Azure Database for PostgreSQL Flexible Server + banco da app
#   - Regra de firewall (Azure services + IP público atual)
#   - App Service Plan (Linux)
#   - App Service (runtime Java, sem container)
#
# Uso:
#   cp azure/variables.example.sh azure/variables.sh   # se ainda não fez
#   # edite azure/variables.sh com nomes únicos do seu grupo
#   ./azure/01-create-infrastructure.sh
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib-common.sh"

load_variables
require_azure_cli
require_env AZURE_RESOURCE_GROUP AZURE_LOCATION \
    APP_SERVICE_PLAN APP_SERVICE_NAME APP_SERVICE_SKU \
    POSTGRES_SERVER_NAME POSTGRES_DB_NAME POSTGRES_ADMIN_USER \
    POSTGRES_SKU POSTGRES_TIER POSTGRES_VERSION POSTGRES_STORAGE_GB

prompt_secret_if_missing POSTGRES_ADMIN_PASSWORD \
    "Senha do administrador do PostgreSQL (mín. 8 caracteres, maiúscula+número+símbolo)"
require_env POSTGRES_ADMIN_PASSWORD

# --- Runtime Java: consulta os runtimes Linux disponíveis na
#     assinatura/região em vez de supor um valor fixo. -----------
log "Consultando runtimes Linux disponíveis no App Service..."
AVAILABLE_JAVA_RUNTIME="$(az webapp list-runtimes --os-type linux -o tsv 2>/dev/null \
    | grep -E '^JAVA:17-' | head -n1 || true)"
if [ -z "$AVAILABLE_JAVA_RUNTIME" ]; then
    warn "Não foi possível confirmar automaticamente o runtime Java 17 disponível; usando 'JAVA:17-java17' como padrão documentado pela Microsoft."
    AVAILABLE_JAVA_RUNTIME="JAVA:17-java17"
fi
log "Runtime selecionado: $AVAILABLE_JAVA_RUNTIME (compatível com Java 17 do projeto, ver pom.xml)"

SUBSCRIPTION_NAME="$(az account show --query name -o tsv)"
SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
MY_IP="$(curl -s --max-time 5 https://api.ipify.org || echo "")"

echo
echo "============================================================"
echo " Pet Family API — recursos que serão criados"
echo "============================================================"
echo " Assinatura:            $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
echo " Resource Group:        $AZURE_RESOURCE_GROUP"
echo " Região:                $AZURE_LOCATION"
echo " App Service Plan:      $APP_SERVICE_PLAN (SKU $APP_SERVICE_SKU, Linux)"
echo " App Service:           $APP_SERVICE_NAME"
echo "   -> URL pública:      https://${APP_SERVICE_NAME}.azurewebsites.net"
echo " Runtime:                $AVAILABLE_JAVA_RUNTIME"
echo " PostgreSQL Server:     $POSTGRES_SERVER_NAME (SKU $POSTGRES_SKU / $POSTGRES_TIER, PG $POSTGRES_VERSION, ${POSTGRES_STORAGE_GB}GB)"
echo " Banco de dados:        $POSTGRES_DB_NAME"
echo " Firewall:              AllowAzureServices + IP atual (${MY_IP:-não detectado})"
echo "------------------------------------------------------------"
echo " Custo: recursos B1 (App Service) e Burstable B1ms (Postgres)"
echo " são os menores SKUs de uso geral do Azure, adequados para"
echo " atividade acadêmica. Disponibilidade de SKU e preço exato"
echo " dependem da assinatura e região — confirme no Azure Pricing"
echo " Calculator antes de prosseguir se tiver dúvida sobre custo."
echo "============================================================"
echo

confirm "Isso cria recursos PAGOS na assinatura acima."

log "Criando Resource Group..."
az group create \
    --name "$AZURE_RESOURCE_GROUP" \
    --location "$AZURE_LOCATION" \
    --output none

log "Criando Azure Database for PostgreSQL Flexible Server (pode levar alguns minutos)..."
az postgres flexible-server create \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$POSTGRES_SERVER_NAME" \
    --location "$AZURE_LOCATION" \
    --admin-user "$POSTGRES_ADMIN_USER" \
    --admin-password "$POSTGRES_ADMIN_PASSWORD" \
    --sku-name "$POSTGRES_SKU" \
    --tier "$POSTGRES_TIER" \
    --version "$POSTGRES_VERSION" \
    --storage-size "$POSTGRES_STORAGE_GB" \
    --public-access 0.0.0.0 \
    --yes \
    --output none
# "--public-access 0.0.0.0" é um valor especial do Azure CLI: habilita
# acesso público e já cria a regra "AllowAllAzureServicesAndResourcesWithinAzureIps"
# (necessária para o App Service alcançar o banco). Nenhum IP pessoal
# fica liberado por esse comando — o IP do cliente atual é tratado
# à parte, logo abaixo, com detecção dinâmica (nunca hardcoded).

log "Criando banco de dados da aplicação ($POSTGRES_DB_NAME)..."
az postgres flexible-server db create \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --server-name "$POSTGRES_SERVER_NAME" \
    --database-name "$POSTGRES_DB_NAME" \
    --output none

if [ -n "$MY_IP" ]; then
    log "Liberando o IP público atual ($MY_IP) para acesso via psql..."
    az postgres flexible-server firewall-rule create \
        --resource-group "$AZURE_RESOURCE_GROUP" \
        --name "$POSTGRES_SERVER_NAME" \
        --rule-name "AllowClientAtual" \
        --start-ip-address "$MY_IP" \
        --end-ip-address "$MY_IP" \
        --output none
else
    warn "Não foi possível detectar o IP público atual. Rode azure/04-database-access.sh depois para liberar o IP de onde você vai rodar o psql."
fi

log "Criando App Service Plan (Linux)..."
az appservice plan create \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$APP_SERVICE_PLAN" \
    --location "$AZURE_LOCATION" \
    --is-linux \
    --sku "$APP_SERVICE_SKU" \
    --output none

log "Criando o App Service (runtime $AVAILABLE_JAVA_RUNTIME, sem container)..."
az webapp create \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --plan "$APP_SERVICE_PLAN" \
    --name "$APP_SERVICE_NAME" \
    --runtime "$AVAILABLE_JAVA_RUNTIME" \
    --output none

log "Infraestrutura criada com sucesso."
log "Próximo passo: ./azure/02-configure-app.sh"
