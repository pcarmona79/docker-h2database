#!/bin/sh
set -e

SERVER="java -cp /h2/bin/h2.jar org.h2.tools.Server"
RUNSCRIPT="java -cp /h2/bin/h2.jar org.h2.tools.RunScript"
RUNSHELL="java -cp /h2/bin/h2.jar org.h2.tools.Shell"

if [[ ! -z "$H2_OPTIONS" ]]; then
  url="jdbc:h2:$H2DATA/$H2_DBNAME;$H2_OPTIONS";
else
  url="jdbc:h2:$H2DATA/$H2_DBNAME";
fi

runSql() {
  echo "using url $url"
  $RUNSCRIPT -script "$1" -url "$url" -user "$H2_USER" -password "$H2_PASSWORD"
}

createDb() {
  echo "creating database $url"
  $RUNSHELL -url "$url" -user "$H2_USER" -password "$H2_PASSWORD" -sql "SELECT 1;"
}

mkdir -p "$H2DATA"

if [ ! -f "$H2DATA/.initdb.completed" ]; then

  echo
  if [ ! -z "$(ls -A /docker-entrypoint-initdb.d)" ]; then
    for f in $( ls -d /docker-entrypoint-initdb.d/* | sort -n ); do
      if [[ ! -d "$f" ]]; then
        case "$f" in
          *.sh)     echo "$0: running $f"; . "$f" ;;
          *.sql)    echo "$0: running $f"; runSql "$f" ;;
          *)        echo "$0: ignoring $f" ;;
        esac
      fi
      echo
    done
    touch "$H2DATA/.initdb.completed"
  else
    createDb
  fi

fi

exec "$@"
