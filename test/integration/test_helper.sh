[[ -z "$SHUNIT2"     ]] && SHUNIT2="$(brew --prefix)/bin/shunit2"
[[ -n "$ZSH_VERSION" ]] && setopt shwordsplit

. ${PREFIX:-/usr/local}/share/chjava/chjava.sh

chjava_reset

# Capture certain env variables so we can restore them
original_pwd="$PWD"

setUp() { return; }
tearDown() { return; }
oneTimeTearDown() { return; }