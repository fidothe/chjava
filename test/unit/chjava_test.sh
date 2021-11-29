. ./test/unit/test_helper.sh

function setUp()
{
  test_jdks=("$(mock_jdk emperor-11.jdk 11.0.1 ${test_default_arch})"\
    "$(mock_jdk rockhopper-11.jdk 11.0.8 ${test_default_arch})")
  original_jdks=(${CHJAVA_JDKS[@]})
  original_library_jdk_dir="${CHJAVA_LIBRARY_JDK_DIR}"
  CHJAVA_LIBRARY_JDK_DIR="${test_jvm_library_dir}"
  test_java_version_x="11"
  expected_java_home="${test_jvm_library_dir}/rockhopper-11.jdk/Contents/Home"
}

function test_chjava_X() {
  CHJAVA_JDKS=(${test_jdks[@]})
  chjava "$test_java_version_x" >/dev/null

  assertEquals "did not match $test_java_version_x" "${expected_java_home}" "$JAVA_HOME"
}

function test_chjava_1_does_not_match_11() {
  CHJAVA_JDKS=(${test_jdks[@]})
  chjava "1" 2>/dev/null

  assertEquals "version '1' matched version '11'" 1 $?
}

function test_chjava_11_0_1_matches_11_0_1_123() {
  CHJAVA_JDKS=("$(mock_jdk humboldt-11.jdk 11.0.1_123 ${test_default_arch})")
  chjava "11" 2>/dev/null
  expected_java_home="${test_jvm_library_dir}/humboldt-11.jdk/Contents/Home"

  assertEquals "did not match '11.0.1_123'" "${expected_java_home}" "$JAVA_HOME"
}

function test_chjava_X_plus_arch() {
  CHJAVA_JDKS=(${test_jdks[@]})
  chjava "$test_java_version_x" ${test_default_arch} >/dev/null

  assertEquals "did not match $test_java_version_x" "${expected_java_home}" "$JAVA_HOME"
}

function test_chjava_X_is_name() {
  CHJAVA_JDKS=(${test_jdks[@]})
  chjava "rockhopper-11.jdk" >/dev/null

  assertEquals "did not match $test_java_version_x" "${expected_java_home}" "$JAVA_HOME"
}

function test_chjava_exact_match_first() {
  CHJAVA_JDKS=(${test_jdks[@]})

  chjava "11.0.1"

  assertEquals "did not use the exact match" "${test_jvm_library_dir}/emperor-11.jdk/Contents/Home" "$JAVA_HOME"
}

function test_chjava_system() {
  CHJAVA_JDKS=(${test_jdks[@]})

  chjava "$test_java_version" >/dev/null
  chjava system

  assertNull "did not reset JAVA_HOME" "$JAVA_HOME"
}

function test_chruby_unknown() {
  chjava "does_not_exist" 2>/dev/null

  assertEquals "did not return 1" 1 $?
}

function tearDown() {
  chjava_reset

  CHJAVA_JDKS=(${original_jdks[@]})
  CHJAVA_LIBRARY_JDK_DIR="${original_library_jdk_dir}"
}

SHUNIT_PARENT=$0 . $SHUNIT2