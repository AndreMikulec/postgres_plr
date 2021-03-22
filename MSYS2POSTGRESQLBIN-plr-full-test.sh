
set -v -x

cd "$(dirname "$0")"



export PLRSOURCE=$(cygpath "${PLRSOURCE}")
export R_HOME=$(cygpath "${R_HOME}")



#
# check OLD R PLR (CAN NOT ! - I did not store THIS build anywhere !)
#
##
#
# skip
#



#
# check CUR R PLR
#
export R_HOME_ORIG=${R_HOME}
export R_HOME=${R_HOME}CUR
cd ${PLRSOURCE}
USE_PGXS=1 make installcheck PGUSER=postgres || (cat regression.diffs && false)
cd -
export R_HOME=${R_HOME_ORIG}
