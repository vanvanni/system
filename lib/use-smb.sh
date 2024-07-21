#!/bin/bash
# Use/Smb - Connect to SMB and be able to upload to it
# TODO: Auto create paths -- If you upload to a path, make sure it exists ;)

# Check if smbclient is installed
if command -v smbclient >/dev/null 2>&1; then
    write_gre "Smb::present"
else
    write_red "Smb::failed(MISSING_CLIENT)"
    # Install: sudo apt install -y smbclient
    exit 1
fi

SMBC=$(whereis smbclient | awk '{print $2}')

function smb_upload() {
    local FILE=$1
    local PATH=$2
    local PATH_NAME=$(/bin/basename -- "$FILE")
    write_yel "Smb::transfer"
    $SMBC "$SMB_SHARE" -U "$SMB_USERNAME%$SMB_PASSWORD" -c "put \"$FILE\" \"$PATH/$PATH_NAME\"" >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        write_red "Smb::failed"
        exit 1
    else
        write_gre "Smb::uploaded(${PATH}/${PATH_NAME})"
    fi
}

function smb_delete() {
    echo "// TODO: Implement"
}

function smb_ls() {
    echo "// TODO: Implement"
}