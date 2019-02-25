# Since configuration is shared in umbrella projects, this file
# should only configure the :inkfish application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :inkfish, Inkfish.Repo,
  username: "postgres",
  password: "postgres",
  database: "inkfish_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
