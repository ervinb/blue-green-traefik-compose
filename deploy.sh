#!/bin/bash

set -uo pipefail

source ./config
source ./utils.sh

ACTIVE_SERVICE=${BLUE}
OVERRIDE_TEMPLATE_PATH=templates/proxy.traefik-providers.services.yml.tpl
OVERRIDE_TRAEFIK_DYNAMIC_PATH=proxy/traefik-dynamic/http.routers.docker-localhost.override.yml

function buildAndStartInstance() {
    instance=${1}

    if [[ $instance == ${GREEN} || ${instance} == ${BLUE} ]]; then
        log "Building '${instance}' instance..."
        docker-compose up -d --no-deps --force-recreate --build ${instance} > /dev/null
    else
        fail "Provided instance name should be either '${GREEN}' or '${BLUE}'. Got '${instance}'."
    fi
}

function prepareAlternative() {
    ACTIVE_SERVICE=$(curl ${PROXY_URL}/api/http/routers/docker-localhost@file 2>/dev/null | jq -r '.service')
    log "Active: ${ACTIVE_SERVICE%@*}"

    if [[ ${ACTIVE_SERVICE} == ${BLUE} ]]; then
        export SERVICE_TO_UPDATE=${GREEN}
        buildAndStartInstance ${GREEN}
    else
        export SERVICE_TO_UPDATE=${BLUE}
        buildAndStartInstance ${BLUE}
    fi
}

function activateAlternative() {
    log "Activating '${SERVICE_TO_UPDATE}' instance in Traefik..."
    envsubst <${OVERRIDE_TEMPLATE_PATH} >${OVERRIDE_TRAEFIK_DYNAMIC_PATH}

    # allow some time for the change to propagate
    sleep 3
}


function deploy() {
    prepareAlternative

    activateAlternative
}

deploy "$@"
