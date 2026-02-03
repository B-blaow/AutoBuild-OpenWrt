#!/usr/bin/env bash
set -euo pipefail

#Use with caution, as it may damage the environment.
# Advanced Cleanup Script for OpenWrt / LEDE Build
# Safe for GitHub Ubuntu Runner


MIN_REQUIRED_GB=50

log() { echo "[$(date +'%F %T')] $*"; }

print_space() {
  df -h /
}

########################################
# Remove Browsers & Web Drivers
########################################
remove_browsers_and_webdrivers() {
  log "Removing browsers and webdrivers..."

  apt-get purge -y \
    google-chrome-stable \
    chromium-browser \
    chromium-codecs-ffmpeg-extra \
    microsoft-edge-stable \
    firefox \
    || true

  rm -rf \
    /usr/bin/google-chrome \
    /opt/google/chrome \
    /usr/lib/chromium* \
    /opt/microsoft \
    /usr/lib/firefox* \
    /usr/local/bin/chromedriver \
    /usr/local/bin/msedgedriver \
    /usr/local/bin/geckodriver \
    /usr/share/selenium \
    || true

  apt-get autoremove -y || true
  apt-get clean || true
}

########################################
# Remove Hosted Toolcache (IMPORTANT)
########################################
remove_toolcache() {
  log "Removing hostedtoolcache..."
  rm -rf /opt/hostedtoolcache || true
}

########################################
# Remove Large Language / SDK Packages
########################################
remove_large_sdks() {
  log "Removing large SDKs and packages..."

  rm -rf \
    /usr/share/dotnet \
    /usr/local/lib/android \
    /opt/ghc \
    /etc/mysql \
    /etc/php \
    /usr/lib/jvm \
    /usr/share/swift \
    /usr/local/share/powershell \
    /usr/share/powershell \
    /opt/microsoft \
    /opt/google \
    /opt/az \
    /usr/local/.ghcup \
    /usr/local/share/chromium \
    /usr/local/share/edge \
    || true
}

########################################
# Remove CodeQL
########################################
remove_codeql() {
  log "Removing CodeQL..."
  rm -rf /opt/hostedtoolcache/CodeQL || true
  rm -rf /usr/local/lib/codeql || true
}

########################################
# Swap Cleanup
########################################
remove_swap() {
  log "Disabling and removing swap..."
  swapoff -a || true
  rm -f /swapfile || true
}

########################################
# Docker Cleanup
########################################
docker_cleanup() {
  log "Cleaning Docker..."

  if command -v docker >/dev/null 2>&1; then
    docker system prune -af || true
    rm -rf /var/lib/docker || true
  fi
}

########################################
# Clean apt / logs / temp
########################################
clean_system() {
  log "Cleaning apt, logs and temp..."

  apt-get clean || true
  rm -rf /var/lib/apt/lists/* || true
  find /var/log -type f -delete || true
  rm -rf /tmp/* /var/tmp/* || true
}

########################################
# Clean User Caches
########################################
clean_user_caches() {
  log "Cleaning user caches..."

  USER_HOME="/home/${SUDO_USER:-$(whoami)}"

  rm -rf \
    /root/.ccache \
    "$USER_HOME/.ccache" \
    /root/.cache \
    "$USER_HOME/.cache" \
    /root/.npm \
    "$USER_HOME/.npm" \
    || true
}

########################################
# Disk Check
########################################
check_free_space() {
  AVAILABLE_GB=$(df -BG --output=avail / | tail -1 | tr -dc '0-9')
  log "Available disk space: ${AVAILABLE_GB}G"

  if [ -z "$AVAILABLE_GB" ]; then
    log "Failed to determine available disk space."
    return 1
  fi

  if [ "$AVAILABLE_GB" -lt "$MIN_REQUIRED_GB" ]; then
    log "ERROR: Not enough disk space (< ${MIN_REQUIRED_GB}GB)."
    return 2
  fi

  log "Disk space check passed."
}

########################################
# Main
########################################
main() {
  log "=== BEFORE CLEAN ==="
  print_space

  remove_browsers_and_webdrivers
  remove_toolcache
  remove_large_sdks
  remove_codeql
  remove_swap
  docker_cleanup
  clean_system
  clean_user_caches

  log "=== AFTER CLEAN ==="
  print_space

  check_free_space
  rc=$?
  if [ $rc -eq 2 ]; then
    exit 1
  elif [ $rc -ne 0 ]; then
    exit $rc
  fi

  log "Cleanup completed successfully."
}

if [ "$EUID" -ne 0 ]; then
  log "Warning: not running as root. Some operations may fail."
fi

main
