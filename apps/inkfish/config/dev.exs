# Since configuration is shared in umbrella projects, this file
# should only configure the :inkfish application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :inkfish, Inkfish.Repo,
  username: "inkfish",
  password: "oobeiGait3ie",
  database: "inkfish_dev",
  hostname: "localhost",
  pool_size: 10

config :paddle, Paddle,
  host: "localhost",
  base: "dc=ferrus,dc=net",
  account_subdn: "ou=people",
  ssl: false,
  port: 389
