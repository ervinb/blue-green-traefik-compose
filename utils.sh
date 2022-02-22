#!/bin/bash

set -uo pipefail

REQUIRED_EXECUTABLES="curl docker-compose jq ab"

function log() {
    echo "[$(date +"%D | %H:%M:%S")] $1"
}

function fail() {
    log "$1"

    exit 1
}

function checkBins() {
    log "Checking executables..."

    for exe in ${REQUIRED_EXECUTABLES}; do
        if ! command -v ${exe} %> /dev/null; then
            fail "'${exe}' missing!"
        fi
    done
}

checkBins