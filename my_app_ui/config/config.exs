# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :my_app_ui,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :my_app_ui, MyAppUiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: MyAppUiWeb.ErrorHTML, json: MyAppUiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MyAppUi.PubSub,
  live_view: [signing_salt: "7eKoQlYX"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  my_app_ui: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  my_app_ui: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :logger,
  backends: [
    {:console, level: :info},
    {File, [file: "log/my_app_ui.log", level: :debug]}
  ],
  compile_time_purge_level: :info

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
IO.inspect(config_env(), label: "inside config.exs of my_app_ui")
import_config "#{config_env()}.exs"
