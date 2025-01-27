import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bank_event_sourcing, BankEventSourcing.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "bank_event_sourcing_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bank_event_sourcing, BankEventSourcingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "XYo2hmyFh64YyuIGTAjXY1hfuCTzqPaoGLyFixpe3NBNP03NRTiFf1l2KjUW8T+k",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
