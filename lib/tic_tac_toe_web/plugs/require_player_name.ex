defmodule TicTacToeWeb.RequirePlayerName do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  alias TicTacToe.Game.Player

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, "player") do
      %Player{name: name} when not is_nil(name) ->
        conn

      _ ->
        redirect(conn, to: "/")
    end
  end
end
