

curl -o THROWAWAYFILE --silent --head --fail -L ${PG_CURL_REMOTE_URL}
if [ $? -eq  0 ]
then
  echo false > $(cygpath ${APPVEYOR_BUILD_FOLDER})/PG_CURL_ERROR.txt
elif
  echo true  > $(cygpath ${APPVEYOR_BUILD_FOLDER})/PG_CURL_ERROR.txt
fi