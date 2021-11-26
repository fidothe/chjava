#!/usr/bin/env bash
#
# Installs and configures chjava.
#

set -e

#
# Constants
#
export PREFIX="${PREFIX:-/usr/local}"

#
# Functions
#
function log() {
  if [[ -t 1 ]]; then
    printf "%b>>>%b %b%s%b\n" "\x1b[1m\x1b[32m" "\x1b[0m" \
                              "\x1b[1m\x1b[37m" "$1" "\x1b[0m"
  else
    printf ">>> %s\n" "$1"
  fi
}

function error() {
  if [[ -t 1 ]]; then
    printf "%b!!!%b %b%s%b\n" "\x1b[1m\x1b[31m" "\x1b[0m" \
                              "\x1b[1m\x1b[37m" "$1" "\x1b[0m" >&2
  else
    printf "!!! %s\n" "$1" >&2
  fi
}

function warning() {
  if [[ -t 1 ]]; then
    printf "%b***%b %b%s%b\n" "\x1b[1m\x1b[33m" "\x1b[0m" \
                        "\x1b[1m\x1b[37m" "$1" "\x1b[0m" >&2
  else
    printf "*** %s\n" "$1" >&2
  fi
}

#
# Install chjava
#
log "Installing chjava ..."
make install

#
# Configuration
#
log "Configuring chjava ..."

config="$($(dirname $0)/rc_generate.sh)"

if [[ -d /etc/profile.d/ ]]; then
  # Bash/Zsh
  log "Installing configuration into /etc/profile.d/ ..."
  echo "$config" > /etc/profile.d/chjava.sh
  log "Setup complete! Please restart the shell"
else
  warning "Could not determine where to add chjava configuration."
  warning "Please add the following configuration where appropriate:"
  echo
  echo "$config"
  echo
fi