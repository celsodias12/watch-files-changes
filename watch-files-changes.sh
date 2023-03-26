#!/usr/bin/env bash

trap "exit" INT TERM ERR
trap "kill 0" EXIT

readonly TIME_TO_SLEEP=0.1

readonly FLAGS_KEYS=('r' 'q')
readonly FLAGS_DESCRIPTIONS=('restart' 'quit')
readonly FLAGS_COMMANDS=("execute_received_main_command" "echo $'\n' && echo Exiting... && exit 0")

readonly OPTIONS_KEYS=('a' 'c' 'i' 'h' 'r')
readonly OPTIONS_EXAMPLES=(
  '[after command] Command to be executed after the command to be monitored'
  '[command] Command to execute on run script'
  '[folders] Folders to ignore (default: .git,.idea,node_modules,.vscode)'
  'Show help'
  '[pattern] Pattern files to monitor (example: *.sh)')

DEBUG=false
MAIN_COMMAND=''
AFTER_COMMAND=''
PATTERN_TO_MONITOR=''
IGNORE_FOLDERS=('.git .idea node_modules .vscode')
HAS_OPTIONS=false

# ################################ FUNCTIONS START ################################

show_help() {
  echo -e '\nUsage: \n'
  for ((i = 0; i < ${#OPTIONS_KEYS[@]}; i++)); do
    echo -e "\t-${OPTIONS_KEYS[$i]} ${OPTIONS_EXAMPLES[$i]}"
  done
}

validate_options() {
  local messages=()

  if [ "$HAS_OPTIONS" = false ]; then
    messages+=('No options were passed')
  fi

  if [ -z "$MAIN_COMMAND" ]; then
    messages+=('No command to execute on run script was passed')
  fi

  if [ -z "$PATTERN_TO_MONITOR" ]; then
    messages+=('No pattern files to monitor was passed')
  fi

  if [ ${#messages[@]} -gt 0 ]; then
    echo $'\n ERROR:'

    for ((i = 0; i < ${#messages[@]}; i++)); do
      echo -e "\t${messages[$i]}"
    done

    exit 1
  fi
}

execute_received_main_command() {
  local readonly after_command=$1
  clear

  cd $PWD

  $MAIN_COMMAND

  if [ ! -z "$after_command" ]; then
    echo $'\n'
    $after_command
  fi
}

log() {
  if [ $DEBUG = true ]; then
    local readonly message=$1

    echo $message
  fi
}

get_bytes_of_path() {
  local readonly path=$1

  echo $(du -bc $path | grep 'total' | grep -o '^[0-9]*')
}

print_flags_keypress() {
  echo $'\n'

  for ((i = 0; i < ${#FLAGS_KEYS[@]}; i++)); do
    echo "Press key ${FLAGS_KEYS[$i]} to ${FLAGS_DESCRIPTIONS[$i]}"
  done
}

parse_string_to_array() {
  local readonly string=$1
  local readonly separator=$2

  local array=()

  IFS=$separator read -ra array <<<"$string"

  echo "${array[@]}"
}

execute_flags_keypress() {
  while true; do
    if [ ${#FLAGS_KEYS[@]} -ne ${#FLAGS_DESCRIPTIONS[@]} ] || [ ${#FLAGS_KEYS[@]} -ne ${#FLAGS_COMMANDS[@]} ]; then
      echo "Error: arrays of FLAGS_KEYS, FLAGS_DESCRIPTIONS and FLAGS_COMMANDS must have the same size"
      exit 1
    fi

    print_flags_keypress

    read -rsn1 pressed_key

    for ((i = 0; i < ${#FLAGS_KEYS[@]}; i++)); do
      if [ $pressed_key = ${FLAGS_KEYS[$i]} ]; then

        eval ${FLAGS_COMMANDS[$i]}

        log "Key ${FLAGS_KEYS[$i]} pressed"
        log "Executed command for ${FLAGS_KEYS[$i]}: ${FLAGS_COMMANDS[$i]}"

      fi
    done
  done
}

main() {
  local size=$(get_bytes_of_path "$PATTERN_TO_MONITOR")

  execute_received_main_command
  print_flags_keypress

  while true; do
    sleep $TIME_TO_SLEEP

    if [ $size -ne $(get_bytes_of_path "$PATTERN_TO_MONITOR") ]; then
      execute_received_main_command "$AFTER_COMMAND"

      print_flags_keypress

    fi

    size=$(get_bytes_of_path "$PATTERN_TO_MONITOR")
  done
}

# ################################ FUNCTIONS END ################################

while getopts 'a::c:i:hr:' OPTION; do
  case "$OPTION" in
  'a')
    AFTER_COMMAND="$OPTARG"
    ;;
  'c')
    MAIN_COMMAND="$OPTARG"
    ;;
  'i')
    IGNORE_FOLDERS=($(parse_string_to_array "$OPTARG" ','))
    ;;
  'r')
    PATTERN_TO_MONITOR="$OPTARG"
    ;;
  :)
    echo 'Option -$OPTARG requires an argument.' >&2
    exit 1
    ;;
  'h' | ?)
    show_help
    exit 0
    ;;
  esac
  HAS_OPTIONS=true
done

validate_options

main &
execute_flags_keypress

wait
