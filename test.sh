#!/bin/bash

set -uo pipefail

source ./config
source ./utils.sh

function checkApp() {
    log "GET ${APP_URL}"
    if ! curl -s -H "Host: ${APP_HOSTNAME}" ${APP_URL}; then
        fail "Application not running!"
    fi
    echo
}

function changeApp() {
    content=$(date)

    echo "${content}" > ./app/index.html
}

function startBench() {
   log "Start AB in the background..."
   ab -n 100000000 -c 10 -k -H "Host: ${APP_HOSTNAME}" ${APP_URL}/ &> ${RESULT_PATH}
}

function stopBench() {
    pkill -SIGINT ab

    log "Waiting for 'ab' to finish"
    while true; do
        printf "."
        [[ -z $(ps uax | grep -E "[a]b -n") ]] && break;

        sleep 0.1
    done
    echo

    log "Result:"
    cat ${RESULT_PATH}
}

function deploy() {
    source ./deploy.sh
}

function test() {
    checkApp

    startBench &

    changeApp

    deploy

    checkApp

    stopBench
}

test $@
