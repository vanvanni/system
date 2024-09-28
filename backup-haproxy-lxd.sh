#!/bin/bash
# Backup: Haproxy and LXD

source lib/script.sh
load "use-env"
load "use-smb"
load "backup-haproxy"
load "backup-lxd"

env "SERVER_NAME SMB_SHARE SMB_USERNAME SMB_PASSWORD"
is_root

RUN_ID=$(rid)
RUN_TIME=$(tz)

write_yel "Script::started(${RUN_ID})"
RUN_DIR="/tmp/${RUN_ID}"
mkdir -p $RUN_DIR

BCK_HAPROXY="${RUN_DIR}/${RUN_TIME}-${SERVER_NAME}-haproxy.tar.gz"
bck_haproxy "$BCK_HAPROXY"

BCK_LXD="${RUN_DIR}/${RUN_TIME}-${SERVER_NAME}-lxd.tar.gz"
bck_lxd "$RUN_DIR" "$BCK_LXD"

bundle "${RUN_DIR}/${RUN_TIME}-${SERVER_NAME}-bck.tar.gz" $BCK_HAPROXY $BCK_LXD
smb_upload "${RUN_DIR}/${RUN_TIME}-${SERVER_NAME}-bck.tar.gz" "${SERVER_NAME}"

sudo rm -rf $RUN_DIR
write_gre "Script::done(${RUN_ID})"