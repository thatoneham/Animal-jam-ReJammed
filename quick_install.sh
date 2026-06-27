#!/bin/bash

# Quick (un)install utility for Linux edition of AJCR
# by @metalfoxdev, 2026

set +x

# Disallow running script as root
if [ $(id -u) = 0 ]; then
   echo "-> Script must NOT run as root!"
   echo "-> Root permissions will be requested if needed."
   exit 1
fi

TMP_DIR=$(mktemp -d)
TAR_NAME="rjlinux.tar.gz"
RE_MATCH=""
TB_REGEX="^rejammed_linux_[0-9]\.[0-9]\.[0-9]_x86_64\.tar\.gz$"

echo "~~ AJCR quick install for Linux ~~"

# Give option to quick uninstall too
echo "-- Please choose an option --"
echo "[1] Install / Update"
echo "[2] Uninstall"
read -p "> " usrAns

if [ "$usrAns" -eq "2" ]; then
  ./uninstall.sh
  exit
elif ! [ "$usrAns" -eq "1" ]; then
  echo "Please give a valid option!"
  exit 1
fi

echo "-> Finding latest version"
GH_JSON="$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2026-03-10" \
  https://api.github.com/repos/thatoneham/Animal-jam-ReJammed/releases/latest \
)"

# Find the linux release tarball
(echo $GH_JSON | jq ".assets[] | .name") | while read i; do
  NOQUOTES=$(echo $i | tr -d '"')
  if [[ $NOQUOTES =~ $TB_REGEX ]]; then
    RE_MATCH=1
    TB_URL=$(echo $GH_JSON | jq ".assets[] | select(.name==$i).browser_download_url")
    TB_URL_NQ=$(echo $TB_URL | tr -d '"')

    echo "-> Found release, downloading"
    curl -L -o "$TMP_DIR/$TAR_NAME" "$TB_URL_NQ"

    echo "-> Extracting release archive"
    cd $TMP_DIR
    mkdir "extracted"
    tar -xvzf "$TAR_NAME" -C "extracted"

    cd extracted
    chmod +x ./install.sh

    echo "-> Running install script"
    sudo ./install.sh

    echo "-> Cleaning up"
    rm -r $TMP_DIR

    echo "-- Quick install complete --"
    echo "You can run this script again in the future to update your existing installation, without losing savedata."
    exit 0
  fi
  if [ -z ${RE_MATCH} ]; then
    echo "Cannot find Linux package in latest release!"
    exit 1
  fi
done
