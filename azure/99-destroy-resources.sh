#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib-common.sh"

load_variables
require_azure_cli
require_env AZURE_RESOURCE_GROUP

if ! az group show --name "$AZURE_RESOURCE_GROUP" >/dev/null 2>&1; then
    log "Resource Group '$AZURE_RESOURCE_GROUP' não existe (ou já foi removido). Nada a fazer."
    exit 0
fi

echo "============================================================"
echo " ATENÇÃO — isso remove PERMANENTEMENTE todos os recursos de:"
echo "   Resource Group: $AZURE_RESOURCE_GROUP"
echo "============================================================"
az resource list --resource-group "$AZURE_RESOURCE_GROUP" --query "[].{Nome:name, Tipo:type}" -o table
echo "============================================================"
echo " Isso inclui o banco PostgreSQL com TODOS os dados (pets,"
echo " consultas, tutores, usuários etc.). Não há como desfazer."
echo "============================================================"

confirm "Confirme a exclusão definitiva do Resource Group '$AZURE_RESOURCE_GROUP'." "EXCLUIR"

log "Removendo Resource Group '$AZURE_RESOURCE_GROUP' (roda em background no Azure)..."
az group delete --name "$AZURE_RESOURCE_GROUP" --yes --no-wait

log "Exclusão solicitada. Acompanhe o progresso com:"
echo "    az group show --name $AZURE_RESOURCE_GROUP"
log "(retorna erro 'ResourceGroupNotFound' quando a exclusão terminar)"
