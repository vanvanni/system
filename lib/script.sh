#!/bin/bash
# Utilties

COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_RESET='\033[0m'
DATE_FORMAT="%m-%d-%H%M"
RANDOM_SIZE=8

function load() {
    source lib/$1.sh
}

function rid() {
    local random=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c $RANDOM_SIZE)
    echo $random
}

function tz() {
    local timestamp=$(date +$DATE_FORMAT)
    echo $timestamp
}

function write_gre() {
    local time=$(date +'%H:%M:%S')
    echo -e "${COLOR_GREEN}[+] ${time} - $1${COLOR_RESET}"
}

function write_red() {
    local time=$(date +'%H:%M:%S')
    echo -e "${COLOR_RED}[-] ${time} - $1${COLOR_RESET}"
}

function write_yel() {
    local time=$(date +'%H:%M:%S')
    echo -e "${COLOR_YELLOW}[+] ${time} - $1${COLOR_RESET}"
}

function bundle() {
    local BUNDLE_FILE="$1"
    shift

    if [ "$#" -lt 2 ]; then
        write_red "Bundle::failed(EXPECTED_MIN_TWO_TARS)"
        return 1
    fi

    write_yel "Bundle::started"

    local BUNDLE_TEMP
    BUNDLE_TEMP=$(mktemp -d) || { echo "Failed to create temporary directory"; return 1; }
    trap 'rm -rf "$BUNDLE_TEMP"' EXIT

    for tarball in "$@"; do
        if [ -f "$tarball" ]; then
            cp "$tarball" "$BUNDLE_TEMP/"
        else
            echo "Warning: File $tarball not found, skipping."
        fi
    done

    tar -zcf "$BUNDLE_FILE" -C "$BUNDLE_TEMP" . >/dev/null 2>&1
    rm -rf $BUNDLE_TEMP

    if [ $? -ne 0 ]; then
        write_red "Bundle::failed"
        exit 1
    else
        write_gre "Bundle::created(${BUNDLE_TEMP})"
    fi
}

function is_root() {
    if [ "$(id -u)" -ne 0 ]; then
        write_red "Script::This script must be run as root."
        exit 1
    fi
}
