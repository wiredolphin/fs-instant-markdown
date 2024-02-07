#!/usr/bin/bash
######################################################################
#                                                                    #
# A simple script that watches a given directory for markdown        #
# files using inotifywait and PUTs the content of modified files     #
# to the instant-markdown-d server.                                  #
# See: https://github.com/instant-markdown/vim-instant-markdown      #
#                                                                    #
# Author: vince.damiani - 2024                                       #
#                                                                    #
######################################################################

host=http://localhost:8090
server_pid=""
update_pid=""

trap ctrl_c INT

function ctrl_c {
	curl $host -X DELETE
	echo "DELETE sent!"
	sleep 1
	exit 0
}

declare -A errors
errors[curl]="Curl utility is required! Aborting!"
errors[imd]="instant-markdown-d (https://github.com/instant-markdown/vim-instant-markdown) is required! Aborting!"

#########################################
# Check existence of required utilities #
#########################################
function check_dependencies {
  command -v curl >/dev/null 2>&1 || { echo ${errors[curl]} >&2; exit 1; }
  command -v instant-markdown-d >/dev/null 2>&1 || { echo ${errors[imd]} >&2; exit 1; }
}

#########################################
# Listen for updates and PUT            #
# new file content                      #
#########################################
function update {
	local source_path="$1"

	inotifywait -q -m -r -e modify "$source_path" |
	while read -r dir action file; do
		if [[ "$action" == "MODIFY" ]]; then
			if [[ "${file##*.}" == "md" ]]; then
				curl $host -H "X-File-Path: ${dir}${file}" --upload-file "${dir}${file}"
			fi
		fi
	done
}

#########################################
#                                       #
#########################################
function main
{
  check_dependencies

  local debug=0
  local verbose=0
  local path=''
  local file_path=''
  local browser=''
  local anchor=''
  local theme=''

  if [[ -z "$*" ]]; then
    :
  else
    declare -a _positional
    while [[ $# -gt 0 ]]; do
      local key="$1"
      case "$key" in
        -h|--help)
          # print help function
          exit 0
          ;;
        -a|--anchor)
          anchor=1
          shift
          ;;
        -b|--browser)
          browser="$2"
          shift
          shift
          ;;
        -d|--debug)
          debug=1
          shift
          ;;
        -v|--verbose)
          verbose=1
          shift
          ;;
        -p|--path)
          path="$2"
          shift # Two times, as we've got arguments
          shift
          ;;
        -t|--theme)
          theme="$2"
          shift
          shift
          ;;
        *)
          shift
          ;;
      esac
      _positional+=( "$key" ) # save it in an array for later
    done
  fi
  set -- "${_positional[@]}" # restore positional parameters

  if [[ -z "$path" ]]; then
    echo "Path parameter (-p|--path parameter [path]) is required!"
    exit 1
  fi

  [ -z "$theme" ] && theme="basic"
  declare -a opt=( --theme $theme)
  [ -n "$browser" ] && opt+=( --browser $browser)
  [ "$anchor" = 1 ] && opt+=( --anchor )
  [ "$verbose" = 1 ] && opt+=( --verbose )

  [ $debug = 1 ] && echo "Starging instant-markdown-d server..."
  instant-markdown-d "${opt[@]}" &
  server_pid=$!

  # Listen for updates
  [ $debug = 1 ] && echo "Watching $path"
  update "$path" "$file_path" &
  update_pid=$!

  while [[ 1 ]]; do
    if [ -z "$(ps -p $server_pid -o pid=)" ]; then
      kill -9 $update_pid
      exit 0
    fi
    sleep 1
  done
}

main "$@"







