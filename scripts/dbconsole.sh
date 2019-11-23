#!/bin/bash
CMD=`mix db.console | tail -n 1`
bash -c "$CMD"
