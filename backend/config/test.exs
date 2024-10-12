import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ex_commerce, ExCommerce.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "changeme"),
  hostname: System.get_env("POSTGRES_HOST", "db"),
  database: System.get_env("POSTGRES_DB", "ecom_dev#{System.get_env("MIX_TEST_PARTITION")}"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_commerce, ExCommerceWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "j1U0mJyzvrkX9M+5kXzc062xG1InPzqQ9Shvj0bFsKIzW5q0G45VzKJ/OgeceXqc",
  server: false

# In test we don't send emails
config :ex_commerce, ExCommerce.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Reduce complexity of password hashing to speed up tests
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8
