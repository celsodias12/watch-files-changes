#!/usr/bin/env bash

trap "exit" INT TERM ERR
trap "kill 0" EXIT

set -e

readonly PACKAGE_NAME='watch-files-changes'
readonly PACKAGE_INSTALL_PATH="/usr/local/bin/$PACKAGE_NAME"

check_if_package_installed() {
  if ([ -f $PACKAGE_INSTALL_PATH ]); then
    echo "package '$PACKAGE_NAME' was installed"
    exit 1
  fi
}

check_if_package_dependencies_installed() {
  local readonly dependencies=('ls' 'base64' 'read' 'sleep' 'grep' 'wc')

  for i in "${dependencies[@]}"; do
    if [ -z "$(command -v $i)" ]; then
      echo "error: $i is not installed"
      exit 1
    fi
  done

}

install_package() {
  local readonly file_name="watch-files-changes.sh"
  local readonly url_download_package="https://raw.githubusercontent.com/celsodias12/watch-files-changes/main/$file_name"

  sudo wget "$url_download_package"

  sudo mv "$file_name" "$PACKAGE_NAME"

  sudo mv "$PACKAGE_NAME" "$PACKAGE_INSTALL_PATH"

  sudo chmod +x "$PACKAGE_INSTALL_PATH"

  echo "package '$PACKAGE_NAME' installed successfully"
}

check_if_package_dependencies_installed &&
  check_if_package_installed &&
  install_package
