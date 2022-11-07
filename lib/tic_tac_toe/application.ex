defmodule TicTacToe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias TicTacToe.Storage

  @impl true
  def start(_type, _args) do
    children = [
      TicTacToeWeb.Telemetry,
      {Phoenix.PubSub, name: TicTacToe.PubSub},
      TicTacToeWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: TicTacToe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def start_phase(:init_ets_tables, :normal, _opts) do
    Storage.init_tables()
  end

  @impl true
  def config_change(changed, _new, removed) do
    TicTacToeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
