# Since configuration is shared in umbrella projects, this file
# should only configure the :inkfish application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :inkfish,
  ecto_repos: [Inkfish.Repo]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :inkfish, :time_zone, "America/New_York"

import_config "#{Mix.env()}.exs"
