#!/bin/bash

CMD=`mix db.dump | tail -n 1`
FILE=/tmp/dump-`date +%Y%m%d-%s`.sql

if [[ $# -ne 1 ]]; then
    bash -c "$CMD" > $FILE
    echo "Dumped to: $FILE"
else
    bash -c "$CMD" > $1
fi

