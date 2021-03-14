
set -v -x



#
# mypaint/windows/msys2-build.sh
# https://github.com/mypaint/mypaint/blob/4141a6414b77dcf3e3e62961f99b91d466c6fb52/windows/msys2-build.sh
#
# also functions: loginfo() logok() logerror()
#
# ANSI control codes
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

loginfo() {
  set +v +x
  echo -ne "${CYAN}"
  echo -n "$@"
  echo -e "${NC}"
  set -v -x
}

logok() {
  set +v +x
  echo -ne "${GREEN}"
  echo -n "$@"
  echo -e "${NC}"
  set -v -x
}

logerr() {
  set +v +x
  echo -ne "${RED}ERROR: "
  echo -n "$@"
  echo -e "${NC}"
  set -v -x
}



loginfo "BEGIN file PKGBUILD"



# Maintainer: Andre Mikulec <Andre_Mikulec@Hotmail.com>
_realname=postgres-plr
pkgbase=${_realname}
pkgname="${_realname}"
pkgver=8.4.1
pkgrel=1
pkgdesc="PL/R - PostgreSQL support for R as a procedural language (PL)"
arch=('any')

depends=("tar")
makedepends=("${MINGW_PACKAGE_PREFIX}-gcc"
             "flex"
             "bison"
             "make"
             "perl")

license=("GPL")



export PGSOURCE=$(cygpath -u "${PGSOURCE}")
export PLRSOURCE=$(cygpath -u "${PLRSOURCE}")
export PGINSTALL=$(cygpath -u "${PGINSTALL}")
export R_HOME=$(cygpath -u "${R_HOME}")
export ZIPTMP=$(cygpath -u "${ZIPTMP}")



# hopefully should not matter, but I feel more compfortable - I had an error - so MATTERS
export APPVEYOR_BUILD_FOLDER=$(cygpath -u "${APPVEYOR_BUILD_FOLDER}")



# everytime I enter MSYS2 (using any method), this is
# pre-pended to the beginning of the path . . .
# /mingw64/bin:/usr/local/bin:/usr/bin:/bin:
# or
# /mingw32/bin:/usr/local/bin:/usr/bin:/bin:

# but I want Strawberry Perl to be in front, so I will manually do that HERE now
export PATH=${APPVEYOR_BUILD_FOLDER}/${BETTERPERL}/perl/bin:$PATH

# also, so I need "pexports", that is needed when,
# I try to use "postresql source code from git" to build postgres
# ("pexports" is not needed when I use the "downloadable postgrsql" source code)
export PATH=$PATH:${APPVEYOR_BUILD_FOLDER}/${BETTERPERL}/c/bin

which perl
which pexports



export

loginfo "BEGIN file PKGBUILD pwd"
pwd
loginfo "END   file PKGBUILD pwd"



package() {

  loginfo "BEGIN PKGBUILD package"


  loginfo 'PKGBUILD package pwd'
  pwd
  loginfo 'PKGBUILD package ${srcdir}'
  echo ${srcdir}
  ls -alrt ${srcdir}
  loginfo 'PKGBUILD package ${pkgdir}'
  echo ${pkgdir}
  ls -alrt ${pkgdir}



  export
  local R_HOME_ORIG



  # 18 Tar Command Examples in Linux
  # 2020
  # https://www.tecmint.com/18-tar-command-examples-in-linux/



  loginfo "BEGIN PKGBUILD package POSTGRESQL CONFIGURE + BUILD"
  #
  # configure + build postgres
  #
  cd ${PGSOURCE}
  if [ ! -f "${APPVEYOR_BUILD_FOLDER}/PG_${PG_GIT_BRANCH}.${MSYSTEM}.${BUILD_CONFIG}.configure.build.tar.gz" ]
  then
    ./configure --enable-depend --disable-rpath --prefix=${PGINSTALL}
    # + build
    make
    loginfo "BEGIN tar CREATION"
    ls -alrt ${APPVEYOR_BUILD_FOLDER}
    tar -zcf ${APPVEYOR_BUILD_FOLDER}/PG_${PG_GIT_BRANCH}.${MSYSTEM}.${BUILD_CONFIG}.configure.build.tar.gz *
    ls -alrt ${APPVEYOR_BUILD_FOLDER}/PG_${PG_GIT_BRANCH}.${MSYSTEM}.${BUILD_CONFIG}.configure.build.tar.gz
    loginfo "END   tar CREATION"
  else
    loginfo "BEGIN tar EXTRACTION"
    tar -zxf ${APPVEYOR_BUILD_FOLDER}/PG_${PG_GIT_BRANCH}.${MSYSTEM}.${BUILD_CONFIG}.configure.build.tar.gz
    ls -alrt ${PGSOURCE}
    loginfo "END   tar EXTRACTION"
  fi
  cd -
  loginfo "END   PKGBUILD package POSTGRESQL CONFIGURE"
  pwd



  loginfo "BEGIN PKGBUILD package 'build' to 'source' links follow"
  #
  # Links from the "build environment" back to the "source environment".
  # Links "abs_top_builddir" back to the "abs_top_srcdir" directory.
  #
  cat  "${PGSOURCE}/src/Makefile.global" | grep '^abs'
  cat  "${PGSOURCE}/src/Makefile.global" | grep '^CPPFLAGS'
  #
  # If these are wrong then re-run configure !!!
  # If these are wrong then re-run configure !!!
  # If these are wrong then re-run configure !!!
  #
  loginfo "END   PKGBUILD package 'build' to 'source' links follow"



  loginfo "BEGIN PKGBUILD package PLR FILES SETUP"
  #
  # Note: This MSYS2 (eventual) build of OLD/CUR R PLR
  #       uses the Makefile that uses R_HOME and R_ARCH.
  #
  # copy the PLR code and the correct Makefile to PGSOURCE
  #
  mkdir -p                                      ${PGSOURCE}/contrib/plr
  cp -r -p ${PLRSOURCE}/*                       ${PGSOURCE}/contrib/plr
  #
  loginfo "echo END  PKGBUILD package PLR FILES SETUP"
  ls -alrt ${PLRSOURCE}/LICENSE
  ls -alrt ${PGSOURCE}/contrib/plr
  cat      ${PGSOURCE}/contrib/plr/Makefile


  #
  # Attempt to make a debuggable plr
  #
  cd ${PGSOURCE}/contrib/plr
  if [ "${BUILD_CONFIG}" = "Debug" ]
  then
    echo ""                          >> Makefile
    echo "override CFLAGS += -g -Og" >> Makefile
    echo ""                          >> Makefile
  fi
  cd -
  #
  cat      ${PGSOURCE}/contrib/plr/Makefile


  loginfo "BEGIN PKGBUILD package OLD R PLR BUILD AND INSTALL"
  #
  # build and install OLD R PLR
  #
  export R_HOME_ORIG=${R_HOME}
  export R_HOME=${R_HOME}OLD
  cd ${PGSOURCE}/contrib/plr
  make
  make install
  make clean
  cd -
  export R_HOME=${R_HOME_ORIG}
  loginfo "END  PKGBUILD package OLD R PLR BUILD AND INSTALL"
  pwd
  #
  # some weirdness (something env specific)
  if [ ! -d "${PGINSTALL}/share/postgresql" ]
  then
    local DIRPOSTGRESQL=""
  else
    local DIRPOSTGRESQL="/postgresql"
  fi
  #
  ls -alrt ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
  ls -alrt ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*



  loginfo "BEGIN PKGBUILD package SAVE OLD PLR"
  #
  # save OLD R PLR in a zip
  #
  mkdir -p                                                     ${ZIPTMP}
  cp    -p ${PLRSOURCE}/LICENSE                                ${ZIPTMP}/PLR_LICENSE
  mkdir -p                                                     ${ZIPTMP}/lib
  cp -r -p ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*             ${ZIPTMP}/lib
  mkdir -p                                                     ${ZIPTMP}/share
  cp -r -p ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.* ${ZIPTMP}/share
  #
  export ZIP=BUILD_${APPVEYOR_BUILD_VERSION}_PLR_${PLR_TAG}_${PLR_GIT_COMMIT}_${MSYSTEM}_PG_${PG_GIT_BRANCH}_R_${R_OLD_VERSION}_${BUILD_CONFIG}.tar.gz
  echo ${ZIP}
  cd ${ZIPTMP}
  loginfo "BEGIN tar CREATION"
  tar -zcvf ${APPVEYOR_BUILD_FOLDER}/${ZIP} *
  loginfo "END   tar CREATION"
  cd -
  #
  # clean up
  #
  rm -r ${ZIPTMP}
  rm    ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
  rm    ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*
  #
  loginfo "END   PKGBUILD package SAVE OLD PLR"
  pwd
  ls -alrt ${APPVEYOR_BUILD_FOLDER}/${ZIP}



  loginfo "BEGIN PKGBUILD package CUR R PLR BUILD AND INSTALL"
  #
  # build and install CUR R PLR
  #
  export R_HOME_ORIG=${R_HOME}
  export R_HOME=${R_HOME}CUR
  cd ${PGSOURCE}/contrib/plr
  make
  make install
  make clean
  cd -
  export R_HOME=${R_HOME_ORIG}
  loginfo "END  PKGBUILD package CUR R PLR BUILD AND INSTALL"
  pwd
  #
  # some weirdness (something env specific)
  if [ ! -d "${PGINSTALL}/share/postgresql" ]
  then
    local DIRPOSTGRESQL=""
  else
    local DIRPOSTGRESQL="/postgresql"
  fi
  #
  ls -alrt ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
  ls -alrt ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*



  loginfo "BEGIN PKGBUILD package SAVE CUR PLR"
  #
  # save CUR R PLR in a zip
  #
  mkdir -p                                                     ${ZIPTMP}
  cp    -p ${PLRSOURCE}/LICENSE                                ${ZIPTMP}/PLR_LICENSE
  mkdir -p                                                     ${ZIPTMP}/lib
  cp -r -p ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*             ${ZIPTMP}/lib
  mkdir -p                                                     ${ZIPTMP}/share
  cp -r -p ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.* ${ZIPTMP}/share
  #
  export ZIP=BUILD_${APPVEYOR_BUILD_VERSION}_PLR_${PLR_TAG}_${PLR_GIT_COMMIT}_${MSYSTEM}_PG_${PG_GIT_BRANCH}_R_${R_CUR_VERSION}_${BUILD_CONFIG}.tar.gz
  echo ${ZIP}
  cd ${ZIPTMP}
  loginfo "BEGIN tar CREATION"
  tar -zcvf ${APPVEYOR_BUILD_FOLDER}/${ZIP} *
  loginfo "END   tar CREATION"
  cd -
  #
  # clean up
  #
  rm -r ${ZIPTMP}
  rm    ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
  rm    ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*
  #
  loginfo "END   PKGBUILD package SAVE CUR PLR"
  pwd
  ls -alrt ${APPVEYOR_BUILD_FOLDER}/${ZIP}

  loginfo "END   PKGBUILD package"

}


loginfo "BEGIN near end of PKGBUILD"
loginfo 'PKGBUILD package pwd'
pwd
loginfo 'PKGBUILD package ${srcdir}'
echo ${srcdir}
ls -alrt ${srcdir}
loginfo 'PKGBUILD package ${pkgdir}'
echo ${pkgdir}
ls -alrt ${pkgdir}
loginfo "END near end of PKGBUILD"


loginfo "END   file PKGBUILD"

set +v +x
