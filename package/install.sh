#!/usr/bin/env bash

check_if_package_installed() {
  if ([ -f /usr/local/bin/watch-files-changes ]); then
    echo "package 'watch-files-changes' was installed"
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
  local readonly url_download_package="https://raw.githubusercontent.com/celsodias12/watch-files-changes/main/watch-files-changes.sh"
  local readonly package_path="/usr/local/bin/watch-files-changes"

  sudo wget "$url_download_package"

  sudo mv watch-files-changes.sh "$package_path"

  sudo chmod +x "$package_path"
}

check_if_package_dependencies_installed &&
  check_if_package_installed &&
  install_package
