unset CHJAVA_AUTO_VERSION

function chjava_auto() {
	local dir="$PWD/" specifier read_opt

  if [[ -n "$ZSH_VERSION" ]]; then
    read_opt="-A"
  else
    read_opt="-a"
  fi

	until [[ -z "$dir" ]]; do
		dir="${dir%/*}"

		if { read "${read_opt?}" specifier <"$dir/.java-version"; } 2>/dev/null || [[ -n "$specifier" ]]; then
			if [[ "${specifier[*]}" == "$CHJAVA_AUTO_VERSION" ]]; then return
			else
				CHJAVA_AUTO_VERSION="${specifier[*]}"
				chjava "${specifier[@]}"
				return $?
			fi
		fi
	done

	if [[ -n "$CHJAVA_AUTO_VERSION" ]]; then
		chjava_reset
		unset CHJAVA_AUTO_VERSION
	fi
}

if [[ -n "$ZSH_VERSION" ]]; then
	if [[ ! "$preexec_functions" == *chjava_auto* ]]; then
		preexec_functions+=("chjava_auto")
	fi
elif [[ -n "$BASH_VERSION" ]]; then
	trap '[[ "$BASH_COMMAND" != "$PROMPT_COMMAND" ]] && chjava_auto' DEBUG
fi
