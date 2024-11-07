defmodule MyAppUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MyAppUiWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:my_app_ui, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MyAppUi.PubSub},
      # Start a worker by calling: MyAppUi.Worker.start_link(arg)
      # {MyAppUi.Worker, arg},
      # Start to serve requests, typically the last entry
      MyAppUiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyAppUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MyAppUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
