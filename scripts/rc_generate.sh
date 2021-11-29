#!/usr/bin/env bash
#
# Generates rc file configuration for chjava.
#

#
# Constants
#
export PREFIX="${PREFIX:-/usr/local}"

config="if [ -d "$PREFIX/share/chjava" ]; then
  if [ -n \"\$BASH_VERSION\" ] || [ -n \"\$ZSH_VERSION\" ]; then
    source \"$PREFIX/share/chjava/chjava.sh\"
    source \"$PREFIX/share/chjava/auto.sh\"
  fi
fi"

echo "$config"