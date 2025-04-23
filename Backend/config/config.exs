# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :time_manager_app,
  ecto_repos: [TimeManagerApp.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :time_manager_app, TimeManagerAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: TimeManagerAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TimeManagerApp.PubSub,
  live_view: [signing_salt: "psl1oD3G"],
  cookie_options: [
    secure: true,
    same_site: "Strict"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Joken configuration
config :joken, default_signer: [
  signer_alg: "HS256",
  key_octet: "c06xsjgXblacyio1tpWqa4auRNLJA1aic3JY8oySAfQdOLMFybD9QaHDDqeIgWXn"
]

# config :joken, default_signer: "c06xsjgXblacyio1tpWqa4auRNLJA1aic3JY8oySAfQdOLMFybD9QaHDDqeIgWXn"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
