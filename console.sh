#!/bin/bash

export MIX_ENV=prod
export PORT=4080

_build/prod/rel/inkfish/bin/inkfish remote_console
