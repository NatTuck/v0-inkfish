# Since configuration is shared in umbrella projects, this file
# should only configure the :inkfish_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :inkfish_web, InkfishWeb.Endpoint,
  http: [:inet6, port: {:system, "PORT"}],
  url: [host: "inkfish.ccs.neu.edu", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:phoenix_distillery, :vsn)

config :phoenix, :serve_endpoints, true

import_config "../../config/get_secret.exs"

config :inkfish_web, InkfishWeb.Endpoint,
  secret_key_base: get_config.("key_base")

# ## Using releases (distillery)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :inkfish, InkfishWeb.Endpoint, server: true
#
# Note you can't rely on `System.get_env/1` when using releases.
# See the releases documentation accordingly.

