#!/bin/bash

export MIX_ENV=prod
export PORT=4080
export NODEBIN=`pwd`/assets/node_modules/.bin
export PATH="$PATH:$NODEBIN"

echo "Building..."

mkdir -p ~/.config
mkdir -p priv/static

mix deps.get
mix compile

cd apps/inkfish_web
(cd assets && npm install)
(cd assets && webpack --mode production)
mix phx.digest

cd ../../

echo "Generating release..."
mix distillery.release

#echo "Stopping old copy of app, if any..."
#_build/prod/rel/draw/bin/practice stop || true

echo "Starting app..."

_build/prod/rel/inkfish/bin/inkfish foreground
