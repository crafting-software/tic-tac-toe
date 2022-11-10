defmodule TicTacToeWeb.RequirePlayerName do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, "player_name") do
      nil ->
        redirect(conn, to: "/")

      player_name when is_binary(player_name) ->
        conn
    end
  end
end
