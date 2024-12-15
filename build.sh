#!/usr/bin/env bash

set -euo pipefail

# Function to print usage
usage() {
  echo "Usage: $0 <config file>"
  exit 1
}

# Validate input arguments
if [[ $# -lt 1 || ! -f "$1" ]]; then
  usage
fi

# Global variables
WORKSPACE="$(pwd)"
CONFIG_FILE="$(realpath "$1")"
CONFIG_FILENAME="$(basename "$CONFIG_FILE" .config)"
CONFIG_ARRAY=(${CONFIG_FILENAME//;/ }) # Split into array

if [[ ${#CONFIG_ARRAY[@]} -ne 3 ]]; then
  echo "Error: Config file naming must follow '<repo>;<owner>;<name>.config'."
  exit 1
fi

REPO_NAME="${CONFIG_ARRAY[0]}"
REPO_OWNER="${CONFIG_ARRAY[1]}"
REPO_TARGET="${CONFIG_ARRAY[2]}"
DIY_SCRIPT_PATH="$(realpath "$(dirname "$CONFIG_FILE")/diy.sh")"

# Determine repo details
case "$REPO_NAME" in
  openwrt)
    REPO_URL="https://github.com/openwrt/openwrt"
    REPO_BRANCH="master"
    ;;
  lede)
    REPO_URL="https://github.com/coolsnowwolf/lede"
    REPO_BRANCH="master"
    ;;
  *)
    echo "Error: Unsupported repository name in config file."
    exit 1
    ;;
esac

# Clone repository if it doesn't exist
if [[ ! -d "$REPO_NAME" ]]; then
  git clone --depth=1 -b "$REPO_BRANCH" "$REPO_URL" "$REPO_NAME"
fi

# Function to run the build process
run_build() {
  local repo_dir="$1"

  pushd "$repo_dir" > /dev/null

  # Pull latest changes
  git pull

  # Update feeds and install packages
  sed -i "src-git gxnas https://github.com/gxnas/OpenWrt_Build_x64_Packages" feeds.conf.default
  ./scripts/feeds update -a
  ./scripts/feeds install -a

  # Apply custom config and scripts
  cp -f "$CONFIG_FILE" ./.config
  cp -f "$DIY_SCRIPT_PATH" ./diy.sh
  chmod +x ./diy.sh
  ./diy.sh "$REPO_NAME" "$REPO_OWNER"

  # Configure and start build
  make defconfig

  echo "Downloading packages..."
  make download -j8 V=s

  echo "Starting build with $(nproc) threads..."
  if ! make -j"$(nproc)" V=s; then
    echo "Build failed! Retrying with single thread..."
    make -j1 V=s || { echo "Build failed on retry."; exit 1; }
  fi

  # Handle build artifacts
  pushd bin/targets/*/* > /dev/null
  ls -al
  rm -rf packages *.buildinfo *.manifest *.bin sha256sums
  mv -f *.img.gz "$WORKSPACE"
  popd > /dev/null

  popd > /dev/null
}

# Start build
run_build "$REPO_NAME"

# Post-build cleanup
echo "Build directory size:"
du -chd1 "$REPO_NAME"

echo "Build completed successfully."
