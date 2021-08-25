defmodule ExConductor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExConductor.Repo,
      # Start the Telemetry supervisor
      ExConductorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExConductor.PubSub},
      # Start the Endpoint (http/https)
      ExConductorWeb.Presence,
      ExConductorWeb.Endpoint
      # Start a worker by calling: ExConductor.Worker.start_link(arg)
      # {ExConductor.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExConductor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExConductorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
