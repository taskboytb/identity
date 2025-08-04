#!/bin/bash
set -e  # Exit on error

# Source environment variables
if [ -f .env.dev ]; then
    export $(grep -v '^#' .env.dev | xargs)
fi

# Create clean import directory
rm -rf keycloak/import/*
mkdir -p keycloak/import

# Render template with environment variables
echo "Rendering realm template..."
envsubst '${CLIENT_SECRET}' < keycloak/templates/realm-template.json > keycloak/import/realm-import.json

# Verify rendering
if [ ! -s keycloak/import/realm-import.json ]; then
    echo "Error: Rendered file is empty!"
    exit 1
fi

echo "Starting Keycloak..."
docker-compose up -d keycloak