defmodule GameServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GameServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GameServer.PubSub},
      # Start the Endpoint (http/https)
      GameServerWeb.Endpoint
      # Start a worker by calling: GameServer.Worker.start_link(arg)
      # {GameServer.Worker, arg}
    ]

    :ets.new(:users, [:set, :public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GameServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GameServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
