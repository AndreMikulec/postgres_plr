
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



#
# build and install OLD R PLR
#
export R_HOME_ORIG=${R_HOME}
export R_HOME=${R_HOME}OLD
cd ${PLRSOURCE}
USE_PGXS=1 make
USE_PGXS=1 make install
USE_PGXS=1 make clean
cd -
export R_HOME=${R_HOME_ORIG}




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
export ZIP=BUILD_MSYS2POSTGRESQLBIN_${APPVEYOR_BUILD_VERSION}_PLR_${PLR_TAG}_${PLR_GIT_COMMIT}_${MSYSTEM}_PG_${PG_VERSION}_R_${R_OLD_VERSION}_${BUILD_CONFIG}.tar.gz
cd ${ZIPTMP}
tar -zcvf ${APPVEYOR_BUILD_FOLDER}/${ZIP} *
cd -



#
# save for later testing
#
mkdir -p                                                     ${PGINSTALL}OLD
mkdir -p                                                     ${PGINSTALL}OLD/lib${DIRPOSTGRESQL}
cp    -r ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*             ${PGINSTALL}OLD/lib${DIRPOSTGRESQL}
mkdir -p                                                     ${PGINSTALL}OLD/share${DIRPOSTGRESQL}/extension
cp    -r ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.* ${PGINSTALL}OLD/share${DIRPOSTGRESQL}/extension



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
cd ${PLRSOURCE}
USE_PGXS=1 make
USE_PGXS=1 make install
USE_PGXS=1 make clean
cd -
export R_HOME=${R_HOME_ORIG}




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
export ZIP=BUILD_MSYS2POSTGRESQLBIN_${APPVEYOR_BUILD_VERSION}_PLR_${PLR_TAG}_${PLR_GIT_COMMIT}_${MSYSTEM}_PG_${PG_VERSION}_R_${R_CUR_VERSION}_${BUILD_CONFIG}.tar.gz
cd ${ZIPTMP}
tar -zcvf ${APPVEYOR_BUILD_FOLDER}/${ZIP} *
cd -



#
# save for later testing
#
mkdir -p                                                     ${PGINSTALL}CUR
mkdir -p                                                     ${PGINSTALL}CUR/lib${DIRPOSTGRESQL}
cp    -r ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*             ${PGINSTALL}CUR/lib${DIRPOSTGRESQL}
mkdir -p                                                     ${PGINSTALL}CUR/share${DIRPOSTGRESQL}/extension
cp    -r ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.* ${PGINSTALL}CUR/share${DIRPOSTGRESQL}/extension




#
# clean up
#
rm -r ${ZIPTMP}
rm    ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
rm    ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*
