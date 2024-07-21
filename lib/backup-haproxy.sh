#!/bin/bash
# Backup: Full - Haproxy

HAPROXY_DIR="/etc/haproxy"

function bck_haproxy() {
    write_yel "Backup::haproxy"
    local DIR=$1
    sudo tar -zcf "$DIR" "$HAPROXY_DIR" >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        write_red "Backup::failed"
        exit 1
    else
        write_gre "Backup::created(${DIR})"
    fi
}