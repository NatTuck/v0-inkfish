#!/bin/bash

if [[ $MIX_ENV == "prod" ]]; then
    echo "load db disabled in production"
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 output.dump"
    exit 1
fi

mix ecto.drop
mix ecto.create

CMD=`mix db.console | tail -n 1`
bash -c "$CMD -f $1"
