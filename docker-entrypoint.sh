#!/bin/sh
set -e

SERVER="java -cp /h2/bin/h2.jar org.h2.tools.Server"
RUNSCRIPT="java -cp /h2/bin/h2.jar org.h2.tools.RunScript"

runSql() {
  if [[ ! -z "$H2_OPTIONS" ]]; then
    url="jdbc:h2:$H2DATA/$H2_DBNAME;$H2_OPTIONS";
  else
    url="jdbc:h2:$H2DATA/$H2_DBNAME";
  fi
  echo "using url $url"
  $RUNSCRIPT -script "$1" -url "$url" -user "$H2_USER" -password "$H2_PASSWORD"
}

mkdir -p "$H2DATA"

if [ ! -f "$H2DATA/.initdb.completed" ]; then

  echo
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

fi

exec "$@"
