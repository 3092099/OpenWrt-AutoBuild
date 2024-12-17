#!/bin/bash

# ==========================
# OpenWrt Build Configuration Script
# ==========================

# Ensure script exits on error or undefined variable
set -euo pipefail

# Helper function for logging errors
log_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Helper function for logging info
log_info() {
    echo "[INFO] $1"
}

# Verify required environment variables
if [ -z "${CONFIG_OWNER:-}" ] || [ -z "${CONFIG_REPO:-}" ]; then
    log_error "CONFIG_OWNER and CONFIG_REPO must be set before running the script."
fi

# Check default-settings directory
find_defaultsettings_dir() {
    local dir
    dir=$(find * -type d -name "default-settings" | head -n 1)
    if [ -z "$dir" ]; then
        log_error "default-settings directory not found."
    fi
    echo "$dir"
}

defaultsettings_dir=$(find_defaultsettings_dir)

# Get current date for versioning
build_date=$(date +%Y-%m-%d)

# Update version and other information based on CONFIG_OWNER
update_version_info() {
    local owner="$1"
    local date="$2"
    local suffix="$3"
    log_info "Updating version info for owner: $owner"

    # Update version string in default settings
    sed -i "s/DISTRIB_REVISION='R[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}'/DISTRIB_REVISION='@R$date'/g" \
        "${defaultsettings_dir}/files/zzz-default-settings"

    # Update custom build information
    sed -i "s/LEDE/OpenWrt_${date}_x64_${suffix} by GXNAS build/g" \
        "${defaultsettings_dir}/files/zzz-default-settings"
}

# Update default IP address based on CONFIG_OWNER
update_default_ip() {
    local owner="$1"
    local config_file="package/base-files/files/bin/config_generate"

    if [ ! -f "$config_file" ]; then
        log_error "config_generate file not found: $config_file"
    fi

    case "$owner" in
        "Full-Router"|"Main-Router")
            sed -i 's/192.168.1.1/192.168.18.1/g' "$config_file"
            ;;
        "Side-Routes"|"Simplified-Router"|"Test-Router")
            sed -i 's/192.168.1.1/192.168.1.11/g' "$config_file"
            ;;
        *)
            log_error "Unknown CONFIG_OWNER: $owner"
            ;;
    esac

    log_info "Default IP updated for $owner"
}

# Main logic for handling different CONFIG_OWNER values
case "$CONFIG_OWNER" in
    "Full-Router")
        update_version_info "$CONFIG_OWNER" "$build_date" "Full-featured Version"
        ;;
    "Main-Router")
        update_version_info "$CONFIG_OWNER" "$build_date" "Main Router Version"
        ;;
    "Side-Routes")
        update_version_info "$CONFIG_OWNER" "$build_date" "Side Router Version"
        ;;
    "Simplified-Router")
        update_version_info "$CONFIG_OWNER" "$build_date" "Simplified Version"
        ;;
    "Test-Router")
        update_version_info "$CONFIG_OWNER" "$build_date" "Test Version"
        ;;
    *)
        log_error "Unsupported CONFIG_OWNER: $CONFIG_OWNER"
        ;;
esac

# Update default IP
update_default_ip "$CONFIG_OWNER"

log_info "Script execution completed successfully."
