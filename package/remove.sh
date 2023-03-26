#!/usr/bin/env bash

readonly PACKAGE_NAME='watch-files-changes'
readonly PACKAGE_INSTALLED_PATH="/usr/local/bin/$PACKAGE_NAME"

check_if_package_installed() {
  if (! [ -f $PACKAGE_INSTALLED_PATH ]); then
    echo "package '$PACKAGE_NAME' was not installed"
    exit 1
  fi
}

remove_package() {

  sudo rm "$PACKAGE_INSTALLED_PATH"

  if (! [ -f "$PACKAGE_INSTALLED_PATH" ]); then
    echo "package '$PACKAGE_NAME' was removed"
  else
    echo "error removing package '$PACKAGE_NAME'"
  fi
}

check_if_package_installed &&
  remove_package
