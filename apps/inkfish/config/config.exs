# Since configuration is shared in umbrella projects, this file
# should only configure the :inkfish application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :inkfish,
  ecto_repos: [Inkfish.Repo]

import_config "#{Mix.env()}.exs"
