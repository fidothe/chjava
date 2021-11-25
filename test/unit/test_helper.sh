[[ -z "$SHUNIT2"     ]] && SHUNIT2="$(brew --prefix)/bin/shunit2"
[[ -n "$ZSH_VERSION" ]] && setopt shwordsplit

test_dir="$PWD/test/unit"
test_jvm_library_dir="$PWD/test/fixtures"
test_default_arch="$(uname -m)"
test_java_version="11"

. ./share/chjava/chjava.sh
chjava_reset

setUp() { return; }
tearDown() { return; }
oneTimeTearDown() { return; }