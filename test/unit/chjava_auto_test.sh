. ./share/chjava/auto.sh
. ./test/unit/test_helper.sh

auto_fixtures_dir="${test_fixtures_dir}/auto"

function build_chjava_auto_fixture() {
  local fixture="${auto_fixtures_dir}/$1"
  mkdir -p "${fixture}"

  echo "$2" > "${fixture}/.java-version"
}

function expected_java_home() {
  echo "${test_jvm_library_dir}/$1/Contents/Home"
}

function setUp() {
  test_jdks=("$(mock_jdk humboldt-17.jdk 17.0.1 ${test_default_arch})"\
    "$(mock_jdk emperor-11.jdk 11.0.1 x86_64)"\
    "$(mock_jdk rockhopper-11.jdk 11.0.8 arm64)")
  original_jdks=(${CHJAVA_JDKS[@]})
  original_library_jdk_dir="${CHJAVA_LIBRARY_JDK_DIR}"
  CHJAVA_LIBRARY_JDK_DIR="${test_jvm_library_dir}"
  CHJAVA_JDKS=(${test_jdks[@]})

  build_chjava_auto_fixture "wants-11-arm64" "11 arm64"
  build_chjava_auto_fixture "wants-11-x86_64" "11 x86_64"
  build_chjava_auto_fixture "wants-17" "17"
  build_chjava_auto_fixture "wants-17/subdir-wants-11" "11 arm64"
  build_chjava_auto_fixture "wants-17/subdir-wants-system" "system"
  mkdir -p "${auto_fixtures_dir}/wants-17/subdir"
  build_chjava_auto_fixture "wants-unknown" "python"

  chjava_reset
  unset CHJAVA_AUTO_VERSION
}

function test_chjava_auto_loaded_in_zsh() {
  [[ -n "$ZSH_VERSION" ]] || return 0

  assertContains "did not add chjava_auto to preexec_functions" \
    "$preexec_functions" \
    "chjava_auto"
}

function test_chjava_auto_loaded_in_bash() {
  [[ -n "$BASH_VERSION" ]] || return 0

  local command=". $PWD/share/chjava/auto.sh && trap -p DEBUG"
  local output="$("$SHELL" -c "$command")"

  assertTrue "did not add a trap hook for chjava_auto" \
    '[[ "$output" == *chjava_auto* ]]'
}

function test_chjava_auto_loaded_twice_in_zsh() {
  [[ -n "$ZSH_VERSION" ]] || return 0

  . ./share/chjava/auto.sh

  assertNotContains "should not add chjava_auto twice" \
    "$preexec_functions" \
    "chjava_auto chjava_auto"
}

function test_chjava_auto_loaded_twice() {
  CHJAVA_AUTO_VERSION="dirty"
  PROMPT_COMMAND="chjava_auto"

  . ./share/chjava/auto.sh

  assertNull "CHJAVA_AUTO_VERSION was not unset" "$CHJAVA_AUTO_VERSION"
}

function test_chjava_auto_enter_project_dir_11_arm64() {
  cd "${auto_fixtures_dir}/wants-11-arm64/" && chjava_auto

  assertEquals "did not switch JAVA_HOME when entering a versioned directory" \
    "$(expected_java_home "rockhopper-11.jdk")" "$JAVA_HOME"
}

function test_chjava_auto_enter_project_dir_11_x86_64() {
  cd "${auto_fixtures_dir}/wants-11-x86_64" && chjava_auto

  assertEquals "did not switch JAVA_HOME when entering a versioned directory" \
    "$(expected_java_home "emperor-11.jdk")" "$JAVA_HOME"
}

function test_chjava_auto_enter_project_dir() {
  cd "${auto_fixtures_dir}/wants-17/" && chjava_auto

  assertEquals "did not switch JAVA_HOME when entering a versioned directory" \
    "$(expected_java_home "humboldt-17.jdk")" "$JAVA_HOME"
}

function test_chjava_auto_enter_subdir_directly()
{
  cd "${auto_fixtures_dir}/wants-17/subdir/" && chjava_auto

  assertEquals "did not switch JAVA_HOME when entering a versioned directory" \
    "$(expected_java_home "humboldt-17.jdk")" "$JAVA_HOME"
}

function test_chjava_auto_enter_subdir_with_java_version()
{
  cd "${auto_fixtures_dir}/wants-17/" && chjava_auto
  cd subdir-wants-11/ && chjava_auto

  assertEquals "did not switch JAVA_HOME when entering a sub-versioned directory" \
    "$(expected_java_home "rockhopper-11.jdk")" "$JAVA_HOME"
}

function test_chjava_auto_enter_subdir_with_java_version_set_to_system()
{
  cd "${auto_fixtures_dir}/wants-17/" && chjava_auto
  cd subdir-wants-system/ && chjava_auto

  assertNull "did not unset JAVA_HOME when entering a sub-versioned directory that asked for it" \
    "$JAVA_HOME"
}

function test_chjava_auto_unknown_java() {
  local expected_auto_version="$(cat "${auto_fixtures_dir}/wants-unknown/.java-version")"

  cd "${auto_fixtures_dir}/wants-17/" && chjava_auto
  cd "${auto_fixtures_dir}/wants-unknown/" && chjava_auto 2>/dev/null

  assertEquals "did not keep the current JAVA_HOME when loading an unknown version" \
    "$(expected_java_home "humboldt-17.jdk")" "$JAVA_HOME"
  assertEquals "did not set CHJAVA_AUTO_VERSION" \
    "$expected_auto_version" "$CHJAVA_AUTO_VERSION"
}

function test_chjava_auto_modified_java_version() {
  cd "${auto_fixtures_dir}/wants-17/" && chjava_auto

  echo "11 arm64" > .java-version
  chjava_auto

  assertEquals "did not detect the modified .java-version file" \
    "$(expected_java_home "rockhopper-11.jdk")" "$JAVA_HOME"
}

function test_chjava_auto_overriding_java_version() {
  cd "${auto_fixtures_dir}/wants-17/" && chjava_auto
  chjava system  && chjava_auto

  assertNull "did not override the JAVA_HOME set in .java-version" "$JAVA_HOME"
}

function test_chjava_auto_leave_project_dir() {
  cd "${auto_fixtures_dir}/wants-17/" && chjava_auto
  cd "${auto_fixtures_dir}/wants-17/.." && chjava_auto

  assertNull "did not reset JAVA_HOME when leaving a versioned directory" \
      "$JAVA_HOME"
}

function tearDown() {
  cd "$original_pwd"
  chjava_reset

  CHJAVA_JDKS=(${original_jdks[@]})
  CHJAVA_LIBRARY_JDK_DIR="${original_library_jdk_dir}"
  rm -rf "$auto_fixtures_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2