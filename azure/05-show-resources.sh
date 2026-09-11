#!/usr/bin/env bash
# ============================================================
# Pet Family API — 05: mostrar recursos criados na Azure
# ============================================================
# Lista Resource Group, App Service Plan, App Service e servidor
# PostgreSQL, com URL pública e status — útil para a gravação do
# vídeo (evidenciar que os recursos existem na Azure).
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib-common.sh"

load_variables
require_azure_cli
require_env AZURE_RESOURCE_GROUP APP_SERVICE_NAME POSTGRES_SERVER_NAME

echo "============================================================"
echo " Resource Group: $AZURE_RESOURCE_GROUP"
echo "============================================================"
az group show --name "$AZURE_RESOURCE_GROUP" \
    --query "{nome:name, regiao:location, status:properties.provisioningState}" \
    -o table

echo
echo "------------------------------------------------------------"
echo " Recursos no grupo"
echo "------------------------------------------------------------"
az resource list --resource-group "$AZURE_RESOURCE_GROUP" \
    --query "[].{Nome:name, Tipo:type, Regiao:location}" \
    -o table

echo
echo "------------------------------------------------------------"
echo " App Service"
echo "------------------------------------------------------------"
az webapp show --resource-group "$AZURE_RESOURCE_GROUP" --name "$APP_SERVICE_NAME" \
    --query "{nome:name, estado:state, urlPadrao:defaultHostName, httpsOnly:httpsOnly, linuxFxVersion:siteConfig.linuxFxVersion}" \
    -o table
echo " URL pública: https://${APP_SERVICE_NAME}.azurewebsites.net"

echo
echo "------------------------------------------------------------"
echo " Azure Database for PostgreSQL Flexible Server"
echo "------------------------------------------------------------"
az postgres flexible-server show --resource-group "$AZURE_RESOURCE_GROUP" --name "$POSTGRES_SERVER_NAME" \
    --query "{nome:name, versao:version, sku:sku.name, estado:state, host:fullyQualifiedDomainName}" \
    -o table

echo
echo "------------------------------------------------------------"
echo " Bancos de dados no servidor"
echo "------------------------------------------------------------"
az postgres flexible-server db list --resource-group "$AZURE_RESOURCE_GROUP" --server-name "$POSTGRES_SERVER_NAME" \
    -o table

echo
echo "------------------------------------------------------------"
echo " Regras de firewall do PostgreSQL"
echo "------------------------------------------------------------"
az postgres flexible-server firewall-rule list --resource-group "$AZURE_RESOURCE_GROUP" --name "$POSTGRES_SERVER_NAME" \
    -o table
