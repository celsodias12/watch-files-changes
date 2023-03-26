#!/usr/bin/env bash

check_if_package_installed() {
  if (! [ -f /usr/local/bin/watch-files-changes ]); then
    echo "package 'watch-files-changes' was not installed"
    exit 1
  fi
}

remove_package() {
  local readonly package_path="/usr/local/bin/watch-files-changes"

  sudo rm "$package_path"

  if (! [ -f "$package_path" ]); then
    echo "package 'watch-files-changes' was removed"
  else
    echo "error removing package 'watch-files-changes'"
  fi
}

check_if_package_installed &&
  remove_package
