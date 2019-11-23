#!/bin/bash

if [[ $MIX_ENV == "prod" ]]; then
    echo "load db disabled in production"
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 output.dump"
    exit 1
fi

CMD=`mix db.consol e | tail -n 1`
bash -c "$CMD -f $1"
