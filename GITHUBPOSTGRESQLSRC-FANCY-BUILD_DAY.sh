
set -v -x

cd "$(dirname "$0")"

echo $(date '+%Ym%md%d') > $(cygpath ${APPVEYOR_BUILD_FOLDER})/FANCY_BUILD_DAY.txt
