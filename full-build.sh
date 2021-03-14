#!/usr/bin/env bash

set -v -x



# ANSI control codes
CYAN='\033[0;36m'
NC='\033[0m' # No Color

loginfo() {
  set +v +x
  echo -ne "${CYAN}"
  echo -n "$@"
  echo -e "${NC}"
  set -v -x
}



loginfo "BEGIN file full-build.sh"



cd "$(dirname "$0")"



# needed by the package to build postgres
pacman -S --noconfirm --needed mingw-w64-{i686,x86_64}-gcc
pacman -S --noconfirm --needed msys/{flex,bison,make,perl}

# needed to save cache and artifacts
pacman -S --noconfirm --needed msys/tar



loginfo "BEGIN makepkg-mingw"
#
# ANDRE --nocheck
#
# Users who do not need it . . . call makepkg with --nocheck flag
# https://wiki.archlinux.org/index.php/Creating_packages#check()
#
# Build package
#
set -o pipefail
MINGW_INSTALLS="${MINGW_INSTALLS_TODO}" makepkg-mingw --nocheck 2>&1 | tee PKGBUILD.log
#
loginfo "END   makepkg-mingw"



loginfo "END   file full-build.sh"

set +v +x