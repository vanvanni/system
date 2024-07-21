#!/bin/bash
# Backup: Full - LXD

LXD_DIR="/var/snap/lxd/common/lxd"

function bck_lxd() {
    write_yel "Backup::lxd"
    local TMP_DIR=$1
    local BACKUP_FILE=$2
    sudo cp -r "$LXD_DIR" "$TMP_DIR"
    sudo tar -zcf "$BACKUP_FILE" "$TMP_DIR/lxd" >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        write_red "Backup::failed"
        exit 1
    else
        write_gre "Backup::created(${BACKUP_FILE})"
    fi
}