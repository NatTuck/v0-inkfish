#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 output.dump"
    exit 1
fi

CMD=`mix db.dump | tail -n 1`
bash -c "$CMD" > $1
