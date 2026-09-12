#!/usr/bin/env bash

export RM_GRUPO="rmXXXXXX"

export AZURE_RESOURCE_GROUP="rg-petfamily-devops"
export AZURE_LOCATION="brazilsouth"

export APP_SERVICE_PLAN="plan-petfamily-${RM_GRUPO}"
export APP_SERVICE_NAME="petfamily-api-${RM_GRUPO}"
export APP_SERVICE_SKU="B1"

export POSTGRES_SERVER_NAME="petfamily-pg-${RM_GRUPO}"
export POSTGRES_DB_NAME="petfamily"
export POSTGRES_ADMIN_USER="petfamilyadmin"
export POSTGRES_SKU="Standard_B1ms"
export POSTGRES_TIER="Burstable"
export POSTGRES_VERSION="16"
export POSTGRES_STORAGE_GB="32"

export CORS_ALLOWED_ORIGINS="*"
export JWT_EXPIRATION_MS="86400000"

export JAR_RELATIVE_PATH="target/petfamily-1.0.0.jar"
