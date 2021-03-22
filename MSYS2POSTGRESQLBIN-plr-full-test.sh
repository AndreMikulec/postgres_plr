
set -v -x

cd "$(dirname "$0")"



export PLRSOURCE=$(cygpath "${PLRSOURCE}")
export R_HOME=$(cygpath "${R_HOME}")




#
# create a cluster and start
#
mkdir -p ./Data
export PGDATA=./Data
export TZ=UTC
initdb -E utf8 --locale=C
pg_ctl start -w



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



pg_ctl stop -w
