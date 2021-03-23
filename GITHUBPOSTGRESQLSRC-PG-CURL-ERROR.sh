
set -v -x

cd "$(dirname "$0")"

curl -o THROWAWAYFILE --silent --head --fail -L ${PG_CURL_REMOTE_URL}
if [ $? -eq 0 ]
then
  echo false > $(cygpath ${APPVEYOR_BUILD_FOLDER})/PG_CURL_ERROR.txt
else
  echo true  > $(cygpath ${APPVEYOR_BUILD_FOLDER})/PG_CURL_ERROR.txt
fi