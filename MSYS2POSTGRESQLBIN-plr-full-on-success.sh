
set -v -x

cd "$(dirname "$0")"


export PLRSOURCE=$(cygpath "${PLRSOURCE}")


cd ${PLRSOURCE}
bash <(curl -s https://codecov.io/bash)
cd -
