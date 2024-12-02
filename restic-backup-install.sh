#!/bin/bash
# Prepare Restic Installation

source lib/script.sh
load "use-env"

env "RESTIC_HOSTNAME RESTIC_USERNAME RESTIC_PORT RESTIC_PASSWORD RESTIC_KEYFILE RESTIC_REPONAME"
is_root

sudo apt-get install restic -y

# Create and secure the password file
echo $RESTIC_PASSWORD > ~/.config/restic/password.txt
chmod 600 ~/.config/restic/password.txt
write_gre "Restic::Password"

# Create and secure the password file
printf '%s\n' "$RESTIC_KEYFILE" > ~/.ssh/backup_key
chmod 600 ~/.ssh/backup_key
write_gre "Restic::Backupkey"

# Create or edit ~/.ssh/config
cat > ~/.ssh/config << EOF
Host restic-storage
    HostName $RESTIC_HOSTNAME
    User $RESTIC_USERNAME
    Port $RESTIC_PORT
    IdentityFile ~/.ssh/backup_key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
chmod 600 ~/.ssh/config
write_gre "Restic::SSHConfig"

# Create restic environment file with specific SSH settings
cat > ~/.config/restic/env << EOF
export RESTIC_REPOSITORY="sftp:restic-storage:/home/$RESTIC_REPONAME"
export RESTIC_PASSWORD_FILE="/root/.config/restic/password.txt"
export RESTIC_REPOSITORY_PORT=$RESTIC_PORT
export RESTIC_SSH_COMMAND="ssh -i ~/.ssh/backup_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
EOF
chmod 600 ~/.config/restic/env
write_gre "Restic::ResticEnv"

source ~/.config/restic/env

restic snapshots > /dev/null 2>&1 || {
    write_red "Initializing new restic repository..."
    restic init || write_red "Repository initialization failed"
}
write_gre "Restic::Initialized"