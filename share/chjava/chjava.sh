CHJAVA_VERSION="0.0.1"
CHJAVA_LIBRARY_JDK_DIR="/Library/Java/JavaVirtualMachines"
CHJAVA_JDKS=()

# /usr/libexec/java_home seems buggy in macOS 11 / 12, so we have to
# handroll the list
for jdk in $(ls ${CHJAVA_LIBRARY_JDK_DIR}); do
  local jdk_arch=$(file "${CHJAVA_LIBRARY_JDK_DIR}/$jdk/Contents/MacOS/libjli.dylib" | rev | cut -d ' ' -f 1 | rev)
  local jdk_version=$(/usr/libexec/PlistBuddy -c "print JavaVM:JVMVersion" "${CHJAVA_LIBRARY_JDK_DIR}/${jdk}/Contents/Info.plist")
  CHJAVA_JDKS+="$jdk:$jdk_version:$jdk_arch"
done
unset jdk

function chjava_reset()
{
	[[ -z "$JAVA_HOME" ]] && return

	unset JAVA_HOME
	hash -r
}

function chjava_use()
{
	export JAVA_HOME="$1"
  echo "$1"
	hash -r
}

function chjava_jdk_name() {
  echo "$1" | cut -d ':' -f 1
}

function chjava_jdk_version() {
  echo "$1" | cut -d ':' -f 2
}

function chjava_jdk_arch() {
  echo "$1" | cut -d ':' -f 3
}

function chjava_list_arch()
{
  local jdk name
  for jdk in "${CHJAVA_JDKS[@]}"; do
    name=$(chjava_jdk_name "$jdk")
    if [[ "${CHJAVA_LIBRARY_JDK_DIR}/${name}" == "$JAVA_HOME" ]]; then
      echo " * ${name} $(chjava_jdk_version $jdk) [$(chjava_jdk_arch $jdk)]"
    else
      echo "   ${name} $(chjava_jdk_version $jdk) [$(chjava_jdk_arch $jdk)]"
    fi
  done
}

function chjava_match()
{
  # request="$1"
  # requset_arch=$2
  local candidates candidate_versions version match
  candidates=()

  for jdk in "${CHJAVA_JDKS[@]}"; do
    version="$(chjava_jdk_version $jdk)"

    if echo "$version" | egrep "^$1" > /dev/null && [[ "$(chjava_jdk_arch $jdk)" == "$2" ]]; then
      candidates+="$jdk"
    fi
  done

  if [[ ${#candidates[@]} -eq 0 ]]; then
    return 1
  fi

  match=$(printf "%s\n" "${candidates[@]}" | sort -V -k 2 -t : | tail -n1)

  chjava_jdk_name "${match}"
}

function chjava()
{
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
			chjava_use "${CHJAVA_LIBRARY_JDK_DIR}/${match}"
			;;
	esac
}