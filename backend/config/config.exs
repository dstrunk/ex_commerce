# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ex_commerce,
  ecto_repos: [ExCommerce.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :ex_commerce, ExCommerceWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ExCommerceWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ExCommerce.PubSub

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ex_commerce, ExCommerce.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_commerce, ExCommerce.Guardian,
  issuer: "ex_commerce",
  secret_key: "lzLBvZJXR9Q6rBSvqO/MHm7bjDn3juIziHxpDIKaNb/n8u4OeBKvY9aTzxaaqbtM"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
