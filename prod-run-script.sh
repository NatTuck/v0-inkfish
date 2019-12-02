#!/bin/bash
export MIX_ENV=prod
export PORT=4081

mix run $1 $2

