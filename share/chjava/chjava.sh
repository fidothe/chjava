CHJAVA_VERSION="0.0.1"
CHJAVA_LIBRARY_JDK_DIR="/Library/Java/JavaVirtualMachines"
CHJAVA_JDKS=()

function chjava_jdk_entry() {
  local jdk_name jdk_arch jdk_version
  jdk_name="$(basename "$1")"
  jdk_arch="$(/usr/bin/file "$1/Contents/MacOS/libjli.dylib" | rev | cut -d ' ' -f 1 | rev)"
  jdk_version="$(/usr/libexec/PlistBuddy -c "print JavaVM:JVMVersion" "$1/Contents/Info.plist")"
  echo "$1:$jdk_name:$jdk_version:$jdk_arch"
}

# /usr/libexec/java_home seems buggy in macOS 11 / 12, so we have to
# handroll the list
for jdk in "${CHJAVA_LIBRARY_JDK_DIR}"/*.jdk; do
  CHJAVA_JDKS+=("$(chjava_jdk_entry "$jdk")")
done
unset jdk

function chjava_reset() {
  [[ -z "$JAVA_HOME" ]] && return

  unset JAVA_HOME
}

function chjava_use() {
  local jdk_home jdk_name jdk_arch jdk_version
  jdk_home="$(chjava_jdk_home $1)"
  jdk_name="$(chjava_jdk_name $1)"
  jdk_arch="$(chjava_jdk_arch $1)"
  jdk_version="$(chjava_jdk_version $1)"
  export JAVA_HOME="$jdk_home"
}

function chjava_jdk_path() {
  echo "$1" | cut -d ':' -f 1
}

function chjava_jdk_home() {
    echo "$(chjava_jdk_path "$1")/Contents/Home"
}

function chjava_jdk_name() {
  echo "$1" | cut -d ':' -f 2
}

function chjava_jdk_version() {
  echo "$1" | cut -d ':' -f 3
}

function chjava_jdk_arch() {
  echo "$1" | cut -d ':' -f 4
}

function chjava_list_arch() {
  local jdk jdk_home
  for jdk in "${CHJAVA_JDKS[@]}"; do
    jdk_home=$(chjava_jdk_home "$jdk")
    if [[ "${jdk_home}" == "$JAVA_HOME" ]]; then
      echo " * $(chjava_jdk_name "$jdk") $(chjava_jdk_version "$jdk") [$(chjava_jdk_arch "$jdk")]"
    else
      echo "   $(chjava_jdk_name "$jdk") $(chjava_jdk_version "$jdk") [$(chjava_jdk_arch "$jdk")]"
    fi
  done
}

function chjava_match() {
  # request="$1"
  # requset_arch=$2
  local candidates version match
  candidates=()

  for jdk in "${CHJAVA_JDKS[@]}"; do
    version="$(chjava_jdk_version "$jdk")"

    if echo "$version" | grep -E "^$1" > /dev/null && [[ "$(chjava_jdk_arch "$jdk")" == "$2" ]]; then
      candidates+=("$jdk")
    fi
  done

  if [[ ${#candidates[@]} -eq 0 ]]; then
    return 1
  fi

  match=$(printf "%s\n" "${candidates[@]}" | sort -V -k 3 -t : | tail -n1)

  echo "${match}"
}

function chjava() {
  case "$1" in
    -h|--help)
      echo "usage: chjava [VERSION|system] [ARCH]"
      ;;
    -V|--version)
      echo "chjava: $CHJAVA_VERSION"
      ;;
    "")
      chjava_list_arch
      ;;
    system) chjava_reset ;;
    *)
      local default_arch arch match
      default_arch="$(uname -m)"
      if [[ -z $2 ]]; then
        arch="$default_arch"
      else
        arch="$2"
      fi

      match=$(chjava_match "$1" "$arch")

      if [[ -z "$match" ]]; then
        echo "chjava: unknown Java: $1" >&2
        return 1
      fi

      shift
      chjava_use "${match}"
      ;;
  esac
}