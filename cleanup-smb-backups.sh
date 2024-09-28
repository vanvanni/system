#!/bin/bash
# Cleanup: Backups

source lib/script.sh
load "use-env"
load "use-smb"

env "SERVER_NAME SMB_SHARE SMB_USERNAME SMB_PASSWORD"
is_root

RUN_TIME=$(tz)
write_gre "Script::started(${RUN_TIME})"

OLD_FILES=$(smb_ls $SERVER_NAME | awk '{print $1}' | grep "gz" | sort -k1,1 | head -n -5)
smb_delete $SERVER_NAME $OLD_FILES

write_gre "Script::done(${RUN_TIME})"