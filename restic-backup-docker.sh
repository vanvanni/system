#!/bin/bash

source lib/script.sh
load "use-env"
set -e

source ~/.config/restic/env
TEMP_DIR=""

# Function for cleaning up temporary files
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        write_yel "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

# Error handler
handle_error() {
    local exit_code=$?
    write_red "An error occurred on line $1"
    cleanup
    exit "$exit_code"
}

trap 'handle_error $LINENO' ERR
trap cleanup EXIT

# Start backup process
write_yel "Starting Docker backup process"
TEMP_DIR=$(mktemp -d)
write_yel "Created temporary directory: $TEMP_DIR"

if ! restic snapshots &>/dev/null; then
    write_red "Missing Restic backup repository"
    exit 1
fi

backup_volume() {
    local volume=$1
    local backup_path=$2

    # Get the actual mount point of the volume in the running container
    local mount_point=$(docker inspect --format '{{range .Mounts}}{{if eq .Name "'"$volume"'"}}{{.Destination}}{{end}}{{end}}' $(docker ps -q --filter volume=$volume) | head -n1)

    if [ -z "$mount_point" ]; then
        write_red "Could not determine mount point for volume: $volume"
        return 1
    fi # This was the problematic line - it had a } instead of fi

    write_yel "Volume $volume is mounted at $mount_point"

    # Create a temporary container that mounts the volume exactly as it's mounted in the original container
    docker run --rm \
        --volumes-from $(docker ps -q --filter volume=$volume) \
        -v "$backup_path:/backup" \
        alpine sh -c "cd '$mount_point' && cp -a . /backup/"
}

write_yel "Starting Docker volume backup"
DOCKER_VOLUMES=$(docker volume ls -q)

for volume in $DOCKER_VOLUMES; do
    write_yel "Processing volume: $volume"

    # Create directory for this volume's backup
    volume_dir="$TEMP_DIR/volumes/$volume"
    mkdir -p "$volume_dir"

    # Check if volume is in use
    containers=$(docker ps -q --filter volume="$volume")

    if [ -n "$containers" ]; then
        write_yel "Volume $volume is in use by containers: $(docker ps --format '{{.Names}}' --filter volume="$volume")"
        # Use our safe backup function for in-use volumes
        backup_volume "$volume" "$volume_dir"
    else
        # For volumes not in use, we can use a simpler approach
        docker run --rm \
            -v "$volume:/source:ro" \
            -v "$volume_dir:/backup" \
            alpine sh -c "cp -a /source/. /backup/"
    fi

    write_gre "Successfully backed up volume: $volume"
done

write_yel "Backing up Docker configuration..."
if [ -f "/etc/docker/daemon.json" ]; then
    mkdir -p "$TEMP_DIR/docker-config"
    cp -r /etc/docker "$TEMP_DIR/docker-config/"
    write_gre "Docker configuration backed up"
fi

# Backup docker-compose files if they exist
if [ -d "/opt/docker-compose" ]; then
    mkdir -p "$TEMP_DIR/docker-config"
    cp -r /opt/docker-compose "$TEMP_DIR/docker-config/"
    write_gre "Docker-compose configurations backed up"
fi

# Create the restic backup
write_yel "Creating restic backup snapshot..."
restic backup \
    --tag docker-backup \
    --tag "$(hostname)" \
    "$TEMP_DIR"

# Prune old backups while maintaining a retention policy
write_yel "Pruning old backups..."
restic forget \
    --keep-daily 2 \
    --keep-weekly 3 \
    --keep-monthly 5 \
    --prune

write_gre "Backup completed successfully!"
