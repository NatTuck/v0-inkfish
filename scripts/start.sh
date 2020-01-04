
#!/bin/bash

export MIX_ENV=prod
export PORT=4080

#echo "Stopping old copy of app, if any..."

#_build/prod/rel/inkfish/bin/inkfish stop || true

echo "Starting app..."

# Foreground for testing and systemd
_build/prod/rel/inkfish/bin/inkfish start | tee /home/inkfish/logs/prod.log
