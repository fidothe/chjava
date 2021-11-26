. ./test/integration/test_helper.sh

function test_chjava_JDKs()
{
  assertNotEquals "did not correctly populate CHJAVA_JDKS" 0 ${#CHJAVA_JDKS[@]}
}

function test_chjava()
{
  local exit_status
  local reported_jdk_version expected_jdk_java_home
  local jdk_entry jdk_name jdk_version jdk_arch

  for jdk_entry in "${CHJAVA_JDKS[@]}"; do
    jdk_name="$(chjava_jdk_name "$jdk_entry")"
    jdk_version="$(chjava_jdk_version "$jdk_entry")"
    jdk_arch="$(chjava_jdk_arch "$jdk_entry")"
    expected_jdk_java_home="${CHJAVA_LIBRARY_JDK_DIR}/${jdk_name}/Contents/Home"
    echo "> chjava $jdk_name ..."
    chjava "$jdk_name"
    exit_status=$?

    assertEquals "did not exit successfully" 0 "$exit_status"

    assertEquals "did not set JAVA_HOME correctly" \
      "$expected_jdk_java_home" \
      "$JAVA_HOME"

    # get /usr/bin/java to report its version (which is a somewhat variable thing).
    reported_jdk_version=$(/usr/bin/java -version 2>&1 | head -n1)

    assertContains "setting JAVA_HOME did not get us the JDK we expected" \
      "$reported_jdk_version" "$jdk_version"

    chjava_reset

    assertEquals "did not unset JAVA_HOME" "" "$JAVA_HOME"
  done
}

SHUNIT_PARENT=$0 . $SHUNIT2