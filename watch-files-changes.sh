#!/bin/bash

trap "exit" INT TERM ERR
trap "kill 0" EXIT

set -e

################################################### FUNCTIONS START ###################################################

show_help() {
  echo -e '\nUsage: \n'
  for ((i = 0; i < ${#OPTIONS_KEYS[@]}; i++)); do
    echo -e "\t-${OPTIONS_KEYS[$i]} ${OPTIONS_EXAMPLES[$i]}"
  done
}

join_array_by_delimiter() {
  local IFS="$1"
  shift
  echo "$*"
}

validate_options() {
  local messages=()

  if [ "$HAS_OPTIONS" = 0 ]; then
    messages+=('No options were passed')
  fi

  if [ -z "$MAIN_COMMAND" ]; then
    messages+=('No command to execute on run script was passed')
  fi

  if [ -z "$DIR_OR_PATH_TO_MONITOR" ]; then
    messages+=('No directory or file to monitor was passed')
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

  kill_process_pid $PROCESS_MAIN_COMMAND_PID
  kill_process_pid $PROCESS_AFTER_COMMAND_PID

  if [ "$DISABLE_CLEAR_SCREEN" -eq 0 ]; then
    clear
  fi

  cd $PWD

  $MAIN_COMMAND &
  PROCESS_MAIN_COMMAND_PID=$!

  if [ ! -z "$after_command" ]; then
    echo $'\n'

    eval $after_command &
    PROCESS_AFTER_COMMAND_PID=$!
  fi
}

log() {
  if [ $DEBUG -eq 1 ]; then
    local readonly message=$1

    echo "$message"
  fi
}

get_encoded_data_from_dir() {
  local readonly path_to_monitor=$1
  local readonly ignore_folders_or_files=("${@:2}")

  local ls_command='ls --all -l --recursive --full-time'
  local ls_option_ignore_folders_or_files=''

  if [ ! -z "$ignore_folders_or_files" ]; then
    for i in "${ignore_folders_or_files[@]}"; do
      ls_option_ignore_folders_or_files+="--ignore=$i "
    done

    ls_command+=" $ls_option_ignore_folders_or_files"
  fi

  echo $($ls_command "$path_to_monitor" 2>/dev/null) | base64

}

parse_string_to_array() {
  local readonly string=$1
  local readonly separator=($2)

  local array=()

  IFS=$separator read -ra array <<<"$string"

  echo "${array[@]}"
}

execute_flags_keypress() {
  while true; do
    if [ ${#FLAGS_KEYS[@]} -ne ${#FLAGS_DESCRIPTIONS[@]} ] || [ ${#FLAGS_KEYS[@]} -ne ${#FLAGS_COMMANDS[@]} ]; then
      echo "Error: arrays of FLAGS_KEYS, FLAGS_DESCRIPTIONS and FLAGS_COMMANDS must have the same encoded_data"
      exit 1
    fi

    read -rsn1 pressed_key

    for ((i = 0; i < ${#FLAGS_KEYS[@]}; i++)); do
      if [ "$pressed_key" = "${FLAGS_KEYS[$i]}" ]; then

        eval ${FLAGS_COMMANDS[$i]}

        log "Key ${FLAGS_KEYS[$i]} pressed"
        log "Executed command for ${FLAGS_KEYS[$i]}: ${FLAGS_COMMANDS[$i]}"
      fi
    done
  done
}

kill_process_pid() {
  local readonly process_pid=$1

  if [ $process_pid -gt 0 ]; then
    local readonly has_running_process=$(ps -p "$process_pid" | grep -v "PID TTY" | wc -l)

    if [ "$has_running_process" = 1 ]; then
      kill -s SIGTERM $process_pid
    fi
  fi
}

main() {
  local encoded_data=$(get_encoded_data_from_dir "$DIR_OR_PATH_TO_MONITOR" "${IGNORE_FOLDERS_OR_FILES[@]}")

  execute_received_main_command "$AFTER_COMMAND"

  local readonly start_number_of_chars=1
  local readonly end_number_of_chars=412

  while true; do
    sleep "$TIME_TO_SLEEP"

    local readonly new_encoded_data=$(get_encoded_data_from_dir "$DIR_OR_PATH_TO_MONITOR" "${IGNORE_FOLDERS_OR_FILES[@]}")

    if [ "$(echo $encoded_data)" != "$(echo $new_encoded_data)" ]; then
      execute_received_main_command "$AFTER_COMMAND"
    fi

    encoded_data=$(get_encoded_data_from_dir "$DIR_OR_PATH_TO_MONITOR" "${IGNORE_FOLDERS_OR_FILES[@]}")
  done
}

#################################################### FUNCTIONS END ####################################################

################################################### VARIABLES START ###################################################

MAIN_COMMAND=''
AFTER_COMMAND=''
IGNORE_FOLDERS_OR_FILES=('.git .gitignore .idea node_modules .vscode .target README.md dist build')
DIR_OR_PATH_TO_MONITOR=''
HAS_OPTIONS=0

PROCESS_MAIN_COMMAND_PID=0
PROCESS_AFTER_COMMAND_PID=0

#################################################### VARIABLES END ####################################################

############################################## VARIABLES READONLY START ###############################################

readonly DEBUG=0
readonly DISABLE_CLEAR_SCREEN=0

readonly TIME_TO_SLEEP=0.1

readonly FLAGS_KEYS=('q')
readonly FLAGS_DESCRIPTIONS=('quit')
readonly FLAGS_COMMANDS=("echo $'\n' && echo Exiting... && exit 0")

readonly OPTIONS_KEYS=('a' 'c' 'd' 'i' 'h')
readonly OPTIONS_EXAMPLES=(
  '[after command] Command to be executed after the command to be monitored'
  '[command] Command to execute on run script'
  '[dir or path] Dir or path to monitor (examples: *.sh or ./ or my-script.sh)'
  "[folders and files] Folders and files to ignore (default: $(join_array_by_delimiter , ${IGNORE_FOLDERS_OR_FILES[*]}))"
  'Show help'
)

############################################### VARIABLES READONLY END ################################################

while getopts 'a::c:d:i:h' OPTION; do
  case "$OPTION" in
  'a')
    AFTER_COMMAND="$OPTARG"
    ;;
  'c')
    MAIN_COMMAND="$OPTARG"
    ;;
  'd')
    DIR_OR_PATH_TO_MONITOR="$OPTARG"
    ;;
  'i')
    IGNORE_FOLDERS_OR_FILES=($(parse_string_to_array "$OPTARG" ','))
    ;;
  :)
    echo 'Option -$OPTARG requires an argument.'
    exit 1
    ;;
  'h' | ?)
    show_help
    exit 1
    ;;
  esac
  HAS_OPTIONS=1
done

validate_options

main &
execute_flags_keypress

wait
