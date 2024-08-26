#!/bin/bash

# Função para mostrar o menu
api_recreate() {
    echo "Recriando API:"
    docker compose -f ./docker-compose.yml up -d --force-recreate api
}

api_logs() {
    echo "Logs Api"
    docker compose -f ./docker-compose.yml logs api
}

ui_recreate() {
    echo "Recriando Frontend:"
    docker compose -f ./docker-compose.yml up -d --force-recreate ui
}


if [ -z "$1" ]; then
    echo "Erro: Nenhuma função fornecida."
    exit 1
fi

funcao=$1

if declare -f "$funcao" > /dev/null; then
    $funcao
else
    echo "Erro: A função '$funcao' não existe"
    exit 1
fi