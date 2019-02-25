# Since configuration is shared in umbrella projects, this file
# should only configure the :inkfish_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :inkfish_web,
  ecto_repos: [Inkfish.Repo],
  generators: [context_app: :inkfish]

# Configures the endpoint
config :inkfish_web, InkfishWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9iEttj9UyPii5b/TLDRI++5qSyPwVvtBCcVg3Gty7p45f3LBVESiz8bIi/nSINNZ",
  render_errors: [view: InkfishWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: InkfishWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
