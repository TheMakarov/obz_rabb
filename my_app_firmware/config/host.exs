import Config

# Add configuration that is only needed when running on the host here.

config :my_app_ui, MyAppUiWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: 8080],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: MyAppUiWeb.ErrorHTML, json: MyAppUiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MyAppUi.PubSub,
  live_view: [signing_salt: "7eKoQlYX"],
  check_origin: false,
  render_errors: [view: MyAppUiWeb.ErrorHTML, accepts: ~w(html json), layout: false],
  secret_key_base: "erPPCHlhAnh0/e9V9Gpx/n+Z9vMsDgg+g2aKttiwq0o/ZPkOrKe/8Zh9tJsfmSKs",
  # Start the server since we're running in a release instead of through `mix`
  server: true,
  # Nerves root filesystem is read-only, so disable the code reloader
  code_reloader: false

config :nerves_runtime,
  kv_backend:
    {Nerves.Runtime.KVBackend.InMemory,
     contents: %{
       # The KV store on Nerves systems is typically read from UBoot-env, but
       # this allows us to use a pre-populated InMemory store when running on
       # host for development and testing.
       #
       # https://hexdocs.pm/nerves_runtime/readme.html#using-nerves_runtime-in-tests
       # https://hexdocs.pm/nerves_runtime/readme.html#nerves-system-and-firmware-metadata

       "nerves_fw_active" => "a",
       "a.nerves_fw_architecture" => "generic",
       "a.nerves_fw_description" => "N/A",
       "a.nerves_fw_platform" => "host",
       "a.nerves_fw_version" => "0.0.0"
     }}
