
set -v -x

cd "$(dirname "$0")"



export PLRSOURCE=$(cygpath "${PLRSOURCE}")
export R_HOME=$(cygpath "${R_HOME}")
export ZIPTMP=$(cygpath "${ZIPTMP}")
export APPVEYOR_BUILD_FOLDER=$(cygpath "${APPVEYOR_BUILD_FOLDER}")



#
# Attempt to make a debuggable plr
#
cd ${PLRSOURCE}
if [ "${BUILD_CONFIG}" = "Debug" ]
then
  echo ""                          >> Makefile
  echo "override CFLAGS += -g -Og" >> Makefile
  echo ""                          >> Makefile
fi
cd -



#
# see my postgresql configuration
#
pg_config



# check postgres is in the path
which postgres
[ ! $? -eq 0 ] && exit 1



# cluster, database(creation), and session default
export TZ=UTC

# cluster
#
# in the users home directory
export PGAPPDIR="$HOME"${MSYSTEM_PREFIX}/"postgres/Data"
#
export     PGDATA=${PGAPPDIR}
export      PGLOG=${PGAPPDIR}/log.txt
export PGLOCALDIR=${MSYSTEM_PREFIX}/share/postgresql/

# database
export PGDATABASE=postgres
export PGPORT=5432
export PGUSER=postgres


winpty -Xallow-non-tty initdb --username=${PGUSER} --pgdata="${PGDATA}" --auth=trust --encoding=utf8 --locale=C
rm -r ${PGDATA}
winpty -Xallow-non-tty initdb --username=${PGUSER} --pgdata="${PGDATA}" --auth=trust --encoding=utf8 --locale=C

pg_ctl start -D "${PGDATA}" -l "${PGLOG}"




#
# build and install OLD R PLR
#
export R_HOME_ORIG=${R_HOME}
export R_HOME=${R_HOME}OLD
export PATH_ORIG=$PATH
# required: create extension plr;
export PATH=${R_HOME}/bin${R_ARCH}:$PATH
which R
[ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
#
cd ${PLRSOURCE}
USE_PGXS=1 make
USE_PGXS=1 make install
###### USE_PGXS=1 make installcheck PGUSER=postgres || (cat regression.diffs && false)
###### [ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
USE_PGXS=1 make clean
cd -
export R_HOME=${R_HOME_ORIG}
export R_HOME=${R_HOME_ORIG}
export PATH=$PATH_ORIG



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

export ZIP=PLR_MSYS2POSTGRESQLBIN_${APPVEYOR_BUILD_VERSION}_${FANCY_BUILD_DAY}_PLR_${PLR_TAG_SHORT}_${PLR_GIT_COMMIT}_${MSYSTEM}_PG_${PG_VERSION_SHORT}_R_${R_OLD_VERSION_SHORT}_${BUILD_CONFIG}.tar.gz
cd ${ZIPTMP}
tar -zcvf ${APPVEYOR_BUILD_FOLDER}/${ZIP} *
cd -



#
# clean up
#
rm -r ${ZIPTMP}
rm    ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
rm    ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*



#
# build and install CUR R PLR
#
export R_HOME_ORIG=${R_HOME}
export R_HOME=${R_HOME}CUR
export PATH_ORIG=$PATH
# required: create extension plr;
export PATH=${R_HOME}/bin${R_ARCH}:$PATH
which R
[ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
#
cd ${PLRSOURCE}
USE_PGXS=1 make
USE_PGXS=1 make install
###### USE_PGXS=1 installcheck PGUSER=postgres || (cat regression.diffs && false)
###### [ ! $? -eq 0 ] && pg_ctl stop -D "${PGDATA}" && exit 1
USE_PGXS=1 make clean
cd -
export R_HOME=${R_HOME_ORIG}
export PATH=$PATH_ORIG



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
export ZIP=PLR_MSYS2POSTGRESQLBIN_${APPVEYOR_BUILD_VERSION}_${FANCY_BUILD_DAY}_PLR_${PLR_TAG_SHORT}_${PLR_GIT_COMMIT}_${MSYSTEM}_PG_${PG_VERSION_SHORT}_R_${R_CUR_VERSION_SHORT}_${BUILD_CONFIG}.tar.gz
cd ${ZIPTMP}
tar -zcvf ${APPVEYOR_BUILD_FOLDER}/${ZIP} *
cd -



#
# clean up
#
rm -r ${ZIPTMP}
rm    ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
rm    ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*



pg_ctl stop -D "${PGDATA}"

