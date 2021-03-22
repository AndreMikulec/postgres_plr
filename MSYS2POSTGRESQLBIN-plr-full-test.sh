
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
initdb --username=${PGUSER} --pgdata="${PGDATA}" --auth=trust --encoding=utf8 --locale=C
rm -fr ${PGDATA}
initdb --username=${PGUSER} --pgdata="${PGDATA}" --auth=trust --encoding=utf8 --locale=C

pg_ctl start -D "${PGDATA}" -l "{PGLOG}"




#
# check OLD R PLR (CAN NOT ! - I did not store THIS build anywhere !)
#
##
#
# skip
#



#
# last built plr
#
# check CUR R PLR
#
export R_HOME_ORIG=${R_HOME}
export R_HOME=${R_HOME}CUR
cd ${PLRSOURCE}
USE_PGXS=1 make installcheck PGUSER=postgres || (cat regression.diffs && false)
cd -
export R_HOME=${R_HOME_ORIG}



pg_ctl stop -D "${PGDATA}"

