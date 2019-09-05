# Since configuration is shared in umbrella projects, this file
# should only configure the :inkfish application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :inkfish, :env, :prod

#import_config "../../config/get_secret.exs"
{get_secret, _} = Code.eval_file "./config/get_secret.exs"

config :paddle, Paddle,
  host: "ldap.ccs.neu.edu",
  base: "dc=ccs,dc=neu,dc=edu",
  account_subdn: "ou=people",
  ssl: true,
  port: 636,
  sslopts: [
    versions: [:'tlsv1.1'],
    ciphers: :ssl.cipher_suites(:all, :'tlsv1.2'),
  ]

config :inkfish, Inkfish.Repo,
  username: "inkfish",
  password: get_secret.("db_pass"),
  database: "inkfish_prod",
  pool_size: 15

