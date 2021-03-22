#
# determine the share and lib directories offset (if any)
#
if [ ! -d "${PGINSTALL}/share/postgresql" ]
then
  DIRPOSTGRESQL=""
else
  DIRPOSTGRESQL="/postgresql"
fi

echo $DIRPOSTGRESQL > $(cygpath ${APPVEYOR_BUILD_FOLDER})/DIRPOSTGRESQL.txt