#!/usr/bin/env bash

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
    if (! [ -x "$(command -v $i)" ]); then
      echo "error: $i is not installed"
      exit 1
    fi
  done

}

install_package() {
  local readonly url_download_package="https://github.com/celsodias12/watch-files-changes/releases/download/1.0.0/watch-files-changes"

  sudo wget "$url_download_package"

  sudo mv $PACKAGE_NAME "$PACKAGE_INSTALL_PATH"

  sudo chmod +x "$PACKAGE_INSTALL_PATH"
}

check_if_package_dependencies_installed &&
  check_if_package_installed &&
  install_package
