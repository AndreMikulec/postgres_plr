#!/usr/bin/env bash

set -v -x



loginfo "BEGIN file plr-full-build.sh"



# mypaint/windows/msys2-build.sh
# https://github.com/mypaint/mypaint/blob/4141a6414b77dcf3e3e62961f99b91d466c6fb52/windows/msys2-build.sh
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



export PGSOURCE=$(cygpath "${PGSOURCE}")
export PLRSOURCE=$(cygpath "${PLRSOURCE}")
export PGINSTALL=$(cygpath "${PGINSTALL}")
export R_HOME=$(cygpath "${R_HOME}")
export ZIPTMP=$(cygpath "${ZIPTMP}")



# I had an error in tarring? - so MATTERS?
export APPVEYOR_BUILD_FOLDER=$(cygpath "${APPVEYOR_BUILD_FOLDER}")



# I am here.  I want to stay here.
echo ${APPVEYOR_BUILD_FOLDER}
pwd
cd "$(dirname "$0")"
pwd



# everytime I enter MSYS2 (using any method), this is
# pre-pended to the beginning of the path . . .
# /mingw64/bin:/usr/local/bin:/usr/bin:/bin:
# or
# /mingw32/bin:/usr/local/bin:/usr/bin:/bin:

# but I want Strawberry Perl to be in front, so I will manually do that HERE now
#
export PATH=${APPVEYOR_BUILD_FOLDER}/${BETTERPERL}/perl/bin:$PATH

which perl

# also, so I need "pexports", that is needed when,
# I try to use "postresql source code from git" to build postgres
# ("pexports" is not needed when I use the "downloadable postgrsql" source code)
#
export PATH=$PATH:${APPVEYOR_BUILD_FOLDER}/${BETTERPERL}/c/bin

which pexports

if [ ! "${PGINSTALL}" == "{MINGW_PREFIX}" ]
then
  # I am probably going to build from source
  # A "build from source" is "out of" the pacman/PKGBUILD system
  # convenience
  export PATH=${PGINSTALL}/bin:$PATH
fi




export



# 18 Tar Command Examples in Linux
# 2020
# https://www.tecmint.com/18-tar-command-examples-in-linux/
#
#
if [ "${PLR_BUILD_METHOD}" == "SRC_THEN_PG_COMPILE" ]
then
  loginfo "BEGIN PKGBUILD package POSTGRESQL CONFIGURE + BUILD"
  #
  # configure + build postgres
  #
  cd ${PGSOURCE}
  if [ ! -f "${APPVEYOR_BUILD_FOLDER}/PG_${PG_GIT_BRANCH}.${MSYSTEM}.configure.build.${PG_BUILD_CONFIG}.tar.gz" ]
  then
    loginfo "BEGIN POSTGRESQL CONFIGURE"
    if [ "${PG_BUILD_CONFIG}" == "Release" ]
    then
      ./configure --enable-depend --disable-rpath --prefix=${PGINSTALL}
    fi
    if [ "${PG_BUILD_CONFIG}" == "Debug" ]
    then
      ./configure --enable-depend --disable-rpath --enable-debug --enable-cassert --prefix=${PGINSTALL}
    fi
    loginfo "END   POSTGRESQL CONFIGURE"
    # + build
    loginfo "BEGIN POSTGRESQL BUILD"
    make
    loginfo "END   POSTGRESQL BUILD"
    loginfo "BEGIN tar CREATION"
    ls -alrt ${APPVEYOR_BUILD_FOLDER}
    tar -zcf ${APPVEYOR_BUILD_FOLDER}/PG_${PG_GIT_BRANCH}.${MSYSTEM}.configure.build.${PG_BUILD_CONFIG}.tar.gz *
    ls -alrt ${APPVEYOR_BUILD_FOLDER}/PG_${PG_GIT_BRANCH}.${MSYSTEM}.configure.build.${PG_BUILD_CONFIG}.tar.gz
    loginfo "END   tar CREATION"
  else
    loginfo "BEGIN tar EXTRACTION"
    tar -zxf ${APPVEYOR_BUILD_FOLDER}/PG_${PG_GIT_BRANCH}.${MSYSTEM}.configure.build.${PG_BUILD_CONFIG}.tar.gz
    ls -alrt ${PGSOURCE}
    loginfo "END   tar EXTRACTION"
  fi
  cd ${APPVEYOR_BUILD_FOLDER}
  loginfo "END   PKGBUILD package POSTGRESQL CONFIGURE + BUILD"
  #
  # I need to install postgress, to get the version or test
  #
  cd ${PGSOURCE}
  loginfo "BEGIN POSTGRESQL INSTALL"
  make install
  loginfo "END   POSTGRESQL INSTALL"
  cd ${APPVEYOR_BUILD_FOLDER}
fi



# e.g. if the same folders are shared e.g. - installation default
# determine the share and lib directories offset (if any)
#
if [ ! -d "${PGINSTALL}/share/postgresql" ]
then
  DIRPOSTGRESQL=""
else
  DIRPOSTGRESQL="/postgresql"
fi


#
# just some info
#
if [ "${PLR_BUILD_METHOD}" == "SRC_THEN_PG_COMPILE" ]
then
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
fi



#
# show the postgresql configuration
# show the postgres version and save it (eventually) into the calling environment
#
loginfo "BEGIN POSTGRESQL ACQUIRE INFO"
pg_config
postgres -V
postgres -V | grep -oP '(?<=\) ).*$' > ${APPVEYOR_BUILD_FOLDER}/PG_VERSION.txt
loginfo "END   POSTGRESQL ACQUIRE INFO"


#
# In the compile, the plr files need to be placed into contrib/plr
#
if [ "${PLR_BUILD_METHOD}" == "SRC_THEN_PG_COMPILE" ]
then
  loginfo "BEGIN copy plr files to contrib"
  #
  # Note: This MSYS2 (eventual) build of OLD/CUR R PLR
  #       uses the Makefile that uses R_HOME and R_ARCH.
  #
  # copy the PLR code and the correct Makefile to PGSOURCE
  #
  mkdir -p                                      ${PGSOURCE}/contrib/plr
  cp -r    ${PLRSOURCE}/*                       ${PGSOURCE}/contrib/plr
  #
  loginfo "echo END  copy plr files to contrib"
  ls -alrt ${PLRSOURCE}/LICENSE
  ls -alrt ${PGSOURCE}/contrib/plr
  cat      ${PGSOURCE}/contrib/plr/Makefile
fi



#
# if necessary, attempt to make a debuggable plr
#
if [ "${PLR_BUILD_METHOD}" == "SRC_THEN_PG_COMPILE" ]
then
  cd ${PGSOURCE}/contrib/plr
fi
if [ "${PLR_BUILD_METHOD}" == "BIN_THEN_USE_PGXS" ]
then
  cd ${PLRSOURCE}
fi
#
if [ "${PLR_BUILD_CONFIG}" = "Debug" ]
then
  echo ""                          >> Makefile
  echo "override CFLAGS += -g -Og" >> Makefile
  echo ""                          >> Makefile
fi
cat                                   Makefile
#
if [ "${PLR_BUILD_METHOD}" == "SRC_THEN_PG_COMPILE" ]
then
  cd ${APPVEYOR_BUILD_FOLDER}
fi
if [ "${PLR_BUILD_METHOD}" == "BIN_THEN_USE_PGXS" ]
then
  cd ${APPVEYOR_BUILD_FOLDER}
fi


#
# required to do the regression tests, are a (started) cluser (and its database)
#

# cluster, database(creation), and session default
export TZ=UTC

# cluster
#
# e.g., in the users home directory
export PGAPPDIR="$HOME"${PGINSTALL}/postgresql/Data

export     PGDATA=${PGAPPDIR}
export      PGLOG=${PGAPPDIR}/log.txt
export PGLOCALDIR=${PGINSTALL}/share${DIRPOSTGRESQL}/

# database params (default)
export PGDATABASE=postgres
export PGPORT=5432
export PGUSER=postgres

# create and start a database
winpty -Xallow-non-tty initdb --username=${PGUSER} --pgdata="${PGDATA}" --auth=trust --encoding=utf8 --locale=C
pg_ctl start -D "${PGDATA}" -l "${PGLOG}"



loginfo "BEGIN OLD R PLR BUILD AND INSTALL"
#
# build and install OLD R PLR
#
export R_HOME_ORIG=${R_HOME}
export R_HOME=${R_HOME}OLD
export PATH_ORIG=$PATH
# required: run some tests (if I desire to do so)
# required: create extension plr;
export PATH=${R_HOME}/bin${R_ARCH}:$PATH
which R
[ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
#
if [ "${PLR_BUILD_METHOD}" == "SRC_THEN_PG_COMPILE" ]
then
cd ${PGSOURCE}/contrib/plr
  make
  make install
  ###### make installcheck PGUSER=postgres || (cat regression.diffs && false)
  ###### [ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
  make clean
  cd ${APPVEYOR_BUILD_FOLDER}
fi
if [ "${PLR_BUILD_METHOD}" == "BIN_THEN_USE_PGXS" ]
then
  cd ${PLRSOURCE}
  USE_PGXS=1 make
  USE_PGXS=1 make install
  ###### USE_PGXS=1 make installcheck PGUSER=postgres || (cat regression.diffs && false)
  ###### [ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
  USE_PGXS=1 make clean
  cd ${APPVEYOR_BUILD_FOLDER}
fi
#
export R_HOME=${R_HOME_ORIG}
export PATH=$PATH_ORIG
loginfo "END  OLD R PLR BUILD AND INSTALL"
#
ls -alrt ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
ls -alrt ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*



loginfo "BEGIN SAVE OLD PLR"
#
# save OLD R PLR in a zip
#
mkdir -p                                                     ${ZIPTMP}
cp       ${PLRSOURCE}/LICENSE                                ${ZIPTMP}/PLR_LICENSE
mkdir -p                                                     ${ZIPTMP}/lib
cp       ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*             ${ZIPTMP}/lib
mkdir -p                                                     ${ZIPTMP}/share
cp       ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.* ${ZIPTMP}/share
#
export ZIP=PLR_${MSYSTEM}_${PLR_TAG_SHORT}_${PLR_GIT_COMMIT}_${PLR_BUILD_CONFIG}_USING_PG_${PG_VERSION_SHORT}_${PLR_BUILD_METHOD}_${PG_BUILD_CONFIG}_LINKED_TO_R_${R_OLD_VERSION_SHORT}_CI_BUILD_VERSION_${APPVEYOR_BUILD_VERSION}_${FANCY_BUILD_DAY}.tar.gz
echo ${ZIP}
cd ${ZIPTMP}
loginfo "BEGIN tar CREATION"
tar -zcvf ${APPVEYOR_BUILD_FOLDER}/${ZIP} *
loginfo "END   tar CREATION"
cd ${APPVEYOR_BUILD_FOLDER}
#
# clean up
#
rm -r ${ZIPTMP}
rm    ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
rm    ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*
#
loginfo "END   SAVE OLD PLR"
pwd
ls -alrt ${APPVEYOR_BUILD_FOLDER}/${ZIP}



loginfo "BEGIN CUR R PLR BUILD AND INSTALL"
#
# build and install CUR R PLR
#
export R_HOME_ORIG=${R_HOME}
export R_HOME=${R_HOME}CUR
export PATH_ORIG=$PATH
# required: run some tests (if I desire to do so)
# required: create extension plr;
export PATH=${R_HOME}/bin${R_ARCH}:$PATH
which R
[ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
#
if [ "${PLR_BUILD_METHOD}" == "SRC_THEN_PG_COMPILE" ]
then
cd ${PGSOURCE}/contrib/plr
  make
  make install
  ###### make installcheck PGUSER=postgres || (cat regression.diffs && false)
  ###### [ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
  make clean
  cd ${APPVEYOR_BUILD_FOLDER}
fi
if [ "${PLR_BUILD_METHOD}" == "BIN_THEN_USE_PGXS" ]
then
  cd ${PLRSOURCE}
  USE_PGXS=1 make
  USE_PGXS=1 make install
  ###### USE_PGXS=1 make installcheck PGUSER=postgres || (cat regression.diffs && false)
  ###### [ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
  USE_PGXS=1 make clean
  cd ${APPVEYOR_BUILD_FOLDER}
fi
#
export R_HOME=${R_HOME_ORIG}
export PATH=$PATH_ORIG
loginfo "END  CUR R PLR BUILD AND INSTALL"
#
ls -alrt ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
ls -alrt ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*



loginfo "BEGIN SAVE CUR PLR"
#
# save CUR R PLR in a zip
#
mkdir -p                                                     ${ZIPTMP}
cp       ${PLRSOURCE}/LICENSE                                ${ZIPTMP}/PLR_LICENSE
mkdir -p                                                     ${ZIPTMP}/lib
cp       ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*             ${ZIPTMP}/lib
mkdir -p                                                     ${ZIPTMP}/share
cp       ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.* ${ZIPTMP}/share
#
export ZIP=PLR_${MSYSTEM}_${PLR_TAG_SHORT}_${PLR_GIT_COMMIT}_${PLR_BUILD_CONFIG}_USING_PG_${PG_VERSION_SHORT}_${PLR_BUILD_METHOD}_${PG_BUILD_CONFIG}_LINKED_TO_R_${R_CUR_VERSION_SHORT}_CI_BUILD_VERSION_${APPVEYOR_BUILD_VERSION}_${FANCY_BUILD_DAY}.tar.gz
echo ${ZIP}
cd ${ZIPTMP}
loginfo "BEGIN tar CREATION"
tar -zcvf ${APPVEYOR_BUILD_FOLDER}/${ZIP} *
loginfo "END   tar CREATION"
cd ${APPVEYOR_BUILD_FOLDER}
#
# clean up
#
rm -r ${ZIPTMP}
rm    ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
rm    ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*
#
loginfo "END   SAVE CUR PLR"
pwd
ls -alrt ${APPVEYOR_BUILD_FOLDER}/${ZIP}




pg_ctl stop -D "${PGDATA}"



loginfo "END   file plr-full-build.sh"

set +v +x