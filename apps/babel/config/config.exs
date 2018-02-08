# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :babel,
  namespace: Babel,
  ecto_repos: [Babel.Repo]

# Configures the endpoint
config :babel, BabelWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bSNEQDu8XqkYtKzBTxYqyzStlx3sHa7xEFqDUE64KxdAKizxmvjETOQxYR36Oluc",
  render_errors: [view: BabelWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Babel.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
