#!/bin/sh

export APP="/app/bin/ex_auctions"

if [ "$1" = 'start' ]; then
  exec $APP start
elif [ "$1" = 'migrate' ]; then
  $APP eval 'ExAuctionsDB.ReleaseTasks.db_create()' && \
  $APP eval 'ExAuctionsDB.ReleaseTasks.db_migrate()'
elif [ "$1" = 'sh' ]; then
  /bin/sh
else
  exec $APP "$@"
fi
