#!/usr/bin/env bash

check_if_dependencies_installed() {
  local readonly dependencies=('shc')

  for dependency in "${dependencies[@]}"; do
    if (! [ -x "$(command -v $dependency)" ]); then
      echo "error: $dependency is not installed"
      exit 1
    fi
  done

}

build() {
  local readonly package_filename='watch-files-changes'
  local readonly current_path="$PWD"

  shc -f "$current_path/$package_filename.sh"

  if [ -f $package_filename.sh.x ]; then
    local readonly output_folder='./output'

    if [ ! -d "$output_folder" ]; then
      mkdir "$output_folder"
    fi

    sleep 0.5

    rm "$package_filename.sh.x.c"

    mv "$package_filename.sh.x" "$output_folder/$package_filename"
  fi
}

check_if_dependencies_installed &&
  build
