#!/usr/bin/env bash
# ============================================================
# Funções compartilhadas pelos scripts azure/*.sh — carregada com
# "source" no início de cada script. Não é executada sozinha.
# ============================================================
set -euo pipefail

SCRIPT_DIR_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()   { echo -e "\033[1;34m[petfamily]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[petfamily][atenção]\033[0m $*"; }
fail()  { echo -e "\033[1;31m[petfamily][erro]\033[0m $*" >&2; exit 1; }

# Carrega azure/variables.sh (não versionado). Se não existir,
# encerra com instrução clara — nunca segue com valores vazios.
load_variables() {
    local vars_file="${SCRIPT_DIR_LIB}/variables.sh"
    if [ ! -f "$vars_file" ]; then
        fail "Arquivo '$vars_file' não encontrado. Rode:
    cp azure/variables.example.sh azure/variables.sh
  e preencha os valores antes de continuar."
    fi
    # shellcheck disable=SC1090
    source "$vars_file"
}

# require_env NOME1 NOME2 ... — encerra com mensagem clara se
# alguma variável obrigatória estiver ausente/vazia.
require_env() {
    local missing=()
    for name in "$@"; do
        if [ -z "${!name:-}" ]; then
            missing+=("$name")
        fi
    done
    if [ "${#missing[@]}" -gt 0 ]; then
        fail "Variável(is) obrigatória(s) ausente(s): ${missing[*]}
  Confira azure/variables.sh (ou exporte no shell antes de rodar o script)."
    fi
}

# Pede uma senha sem ecoar no terminal, se a variável ainda não
# estiver definida no ambiente.
prompt_secret_if_missing() {
    local var_name="$1"
    local prompt_text="$2"
    if [ -z "${!var_name:-}" ]; then
        read -r -s -p "$prompt_text: " value
        echo
        export "$var_name=$value"
    fi
}

# confirm "mensagem" — pede confirmação explícita antes de ações
# destrutivas ou que geram custo. Só prossegue se o usuário digitar
# exatamente a palavra pedida.
confirm() {
    local message="$1"
    local word="${2:-CONFIRMAR}"
    warn "$message"
    read -r -p "Digite '$word' para continuar: " answer
    if [ "$answer" != "$word" ]; then
        fail "Confirmação não recebida. Operação cancelada pelo usuário."
    fi
}

require_azure_cli() {
    command -v az >/dev/null 2>&1 || fail "Azure CLI ('az') não encontrado no PATH. Instale antes de continuar: https://learn.microsoft.com/cli/azure/install-azure-cli"
    az account show >/dev/null 2>&1 || fail "Nenhuma sessão ativa do Azure CLI. Rode 'az login' e selecione a assinatura correta com 'az account set --subscription <id>'."
}
