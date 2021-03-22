
set -v -x

cd "$(dirname "$0")"



export PLRSOURCE=$(cygpath "${PLRSOURCE}")
export R_HOME=$(cygpath "${R_HOME}")


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

rm -fr ${PGDATA}
winpty -Xallow-non-tty initdb --username=${PGUSER} --pgdata="${PGDATA}" --auth=trust --encoding=utf8 --locale=C
rm -fr ${PGDATA}
winpty -Xallow-non-tty initdb --username=${PGUSER} --pgdata="${PGDATA}" --auth=trust --encoding=utf8 --locale=C

winpty -Xallow-non-tty pg_ctl start -D "${PGDATA}" -l "${PGLOG}"



#
# clean up
#
rm    ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
rm    ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*

#
# check OLD R PLR
#
# retrieve to do testing
#
cp -p ${PGINSTALL}OLD/lib${DIRPOSTGRESQL}/plr*.*              ${PGINSTALL}/lib${DIRPOSTGRESQL}
cp -p ${PGINSTALL}OLD/share${DIRPOSTGRESQL}/extension/plr*.*  ${PGINSTALL}/share${DIRPOSTGRESQL}/extension
#
export R_HOME_ORIG=${R_HOME}
export R_HOME=${R_HOME}OLD
cd ${PLRSOURCE}
USE_PGXS=1 make installcheck PGUSER=postgres || (cat regression.diffs && false)
[ ! $? -eq 0 ] && exit 1
cd -
export R_HOME=${R_HOME_ORIG}



#
# clean up
#
rm    ${PGINSTALL}/lib${DIRPOSTGRESQL}/plr*.*
rm    ${PGINSTALL}/share${DIRPOSTGRESQL}/extension/plr*.*

#
# check CUR R PLR
#
# retrieve to do testing
#
cp -p ${PGINSTALL}CUR/lib${DIRPOSTGRESQL}/plr*.*              ${PGINSTALL}/lib${DIRPOSTGRESQL}
cp -p ${PGINSTALL}CUR/share${DIRPOSTGRESQL}/extension/plr*.*  ${PGINSTALL}/share${DIRPOSTGRESQL}/extension
#
export R_HOME_ORIG=${R_HOME}
export R_HOME=${R_HOME}CUR
cd ${PLRSOURCE}
USE_PGXS=1 make installcheck PGUSER=postgres || (cat regression.diffs && false)
[ ! $? -eq 0 ] && exit 1
cd -
export R_HOME=${R_HOME_ORIG}



winpty -Xallow-non-tty pg_ctl stop -D "${PGDATA}"

