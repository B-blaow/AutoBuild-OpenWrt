#!/usr/bin/env bash
set -euo pipefail

# Cleanup script for Build LEDE workflow
# Usage: sudo bash scripts/cleanup.sh
# Note: many operations are destructive (rm -rf). Review before running.

MIN_REQUIRED_GB=32

log() { echo "[$(date +'%F %T')] $*"; }

remove_browsers_and_webdrivers() {
  log "Removing browsers and webdrivers..."
  # Google Chrome
  apt-get purge -y google-chrome-stable || true
  rm -rf /usr/bin/google-chrome /opt/google/chrome || true

  # Chromium
  apt-get purge -y chromium-browser chromium-codecs-ffmpeg-extra || true
  rm -rf /usr/lib/chromium /usr/lib/chromium-browser || true

  # Microsoft Edge
  apt-get purge -y microsoft-edge-stable || true
  rm -rf /usr/bin/microsoft-edge /opt/microsoft/msedge || true

  # Firefox
  apt-get purge -y firefox || true
  rm -rf /usr/lib/firefox /usr/lib/firefox-addons || true

  # WebDrivers
  rm -rf /usr/local/bin/chromedriver || true
  rm -rf /usr/local/bin/msedgedriver || true
  rm -rf /usr/local/bin/geckodriver || true

  # Selenium
  rm -rf /usr/share/selenium || true

  apt-get autoremove -y || true
  apt-get clean || true
  log "Browsers and webdrivers removed."
}

docker_cleanup() {
  log "Starting Docker cleanup (smart detection)..."
  if ! command -v docker >/dev/null 2>&1; then
    log "Docker CLI not found, skipping docker cleanup."
    return
  fi

  if ! docker info >/dev/null 2>&1; then
    log "Docker daemon not running, skipping docker cleanup."
    return
  fi

  log "Docker daemon detected."
  RUNNING_CONTAINERS=$(docker ps -q || true)

  if [ -n "$RUNNING_CONTAINERS" ]; then
    log "Running containers detected, performing system prune only."
    docker system prune -af || true
  else
    log "No running containers, performing deep cleanup and removing /var/lib/docker."
    docker system prune -af || true
    rm -rf /var/lib/docker || true
  fi

  log "Docker cleanup done."
}

clean_apt_logs_temp() {
  log "Cleaning apt, logs and temp files..."
  apt-get clean || true
  find /var/log -type f -delete || true
  rm -rf /tmp/* /var/tmp/* || true
  log "APT, logs and temp cleaned."
}

clean_user_caches() {
  log "Cleaning user caches (ccache, pip, npm)..."
  rm -rf /root/.ccache || true
  rm -rf /home/"${SUDO_USER:-$(whoami)}"/.ccache || true
  rm -rf /root/.cache/pip || true
  rm -rf /home/"${SUDO_USER:-$(whoami)}"/.cache/pip || true
  rm -rf /root/.npm || true
  rm -rf /home/"${SUDO_USER:-$(whoami)}"/.npm || true
  log "User caches cleaned."
}

remove_additional_large_dirs() {
  log "Removing additional large directories..."
  rm -rf /usr/share/dotnet || true
  rm -rf /usr/local/lib/android || true
  rm -rf /opt/ghc || true
  rm -rf /etc/mysql || true
  rm -rf /etc/php || true
  log "Large directories removed."
}

final_housekeeping() {
  log "Final housekeeping: apt lists and docker prune..."
  docker system prune -af || true
  apt-get clean || true
  rm -rf /var/lib/apt/lists/* || true
}

check_free_space() {
  AVAILABLE_GB=$(df -BG --output=avail / | tail -1 | tr -dc '0-9')
  log "Available disk space: ${AVAILABLE_GB}G"
  if [ -z "$AVAILABLE_GB" ]; then
    log "Failed to determine available disk space."
    return 1
  fi
  if [ "$AVAILABLE_GB" -lt "$MIN_REQUIRED_GB" ]; then
    log "ERROR: Not enough disk space (< ${MIN_REQUIRED_GB}GB). Aborting."
    return 2
  fi
  log "Disk space check passed."
}

main() {
  log "=== BEFORE CLEAN ==="
  df -h

  remove_browsers_and_webdrivers
  docker_cleanup
  clean_apt_logs_temp
  clean_user_caches
  remove_additional_large_dirs
  final_housekeeping

  log "=== AFTER CLEAN ==="
  df -h

  check_free_space
  rc=$?
  if [ $rc -eq 2 ]; then
    exit 1
  elif [ $rc -ne 0 ]; then
    exit $rc
  fi

  log "Cleanup completed successfully."
}

# If not run as root, warn and continue (some commands require sudo)
if [ "$EUID" -ne 0 ]; then
  log "Warning: not running as root. Some operations may fail or be skipped. Consider running with sudo."
fi

main
