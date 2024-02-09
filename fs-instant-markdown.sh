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

declare -A errors
errors[no_curl]="Curl utility is required! Aborting..."
errors[no_imd]="instant-markdown-d (see https://github.com/instant-markdown/vim-instant-markdown) is required! Aborting..."
errors[arg_err]="Argument not recognized! Aborting..."
errors[path_req]="Path parameter (-p|--path parameter [path]) is required!"

#########################################
#                                       #
#########################################
function print_help
{
  local c
  c=$(caller)
	c=${c##*/}
	read -r -d '' help <<EOF
fs-instant-markdown - vince.damiani@2024
Watch a directory for markdown files changes,
pass the changed file content to the instant-markdown-d
server.

A running instance of instant-markdown-d is required.
See: https://github.com/wiredolphin/instant-markdown-d/tree/fs-instant-markdown

Usage: ./$c [options]
  -a, --anchor                      Makes instant-markdown-d server in
                                    add id to HTML headings
  -b, --browser <browser>           Set the preferred browser launched
                                    by the instant-markdown-d server
  -d, --debug                       Pass this argument to the
                                    instant-markdown-d
  -v, --verbose                     Make instant-markdown-d verbose
  -p, --path <path>                 Set the path to be watched
  -t, --theme <theme>               Pass the argument to the
                                    instant-markdown-d server
  -h, --help                        Print this help and exits
EOF
	echo "$help"
}

#########################################
# Check existence of required utilities #
#########################################
function check_dependencies {
  command -v curl >/dev/null 2>&1 || { echo ${errors[no_curl]} >&2; exit 1; }
  command -v instant-markdown-d >/dev/null 2>&1 || { echo ${errors[no_imd]} >&2; exit 1; }
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
          echo "${errors[arg_err]}"
          exit 1
          shift
          ;;
      esac
      _positional+=( "$key" ) # save it in an array for later
    done
  fi
  set -- "${_positional[@]}" # restore positional parameters

  if [[ -z "$path" ]]; then
    echo "${errors[path_req]}"
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







