# Since configuration is shared in umbrella projects, this file
# should only configure the :inkfish application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :inkfish, :env, :test

# Configure your database
config :inkfish, Inkfish.Repo,
  username: "inkfish",
  password: "oobeiGait3ie",
  database: "inkfish_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :paddle, Paddle,
  host: "localhost",
  base: "dc=example,dc=com",
  account_subdn: "ou=people",
  ssl: false,
  port: 13389

config :phoenix_integration,
  endpoint: InkfishWeb.Endpoint

config :hound,
  driver: "selenium",
  browser: "firefox",
  port: 4444
