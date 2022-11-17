defmodule TicTacToeWeb.PlayerNameController do
  use TicTacToeWeb, :controller

  alias TicTacToe.Game.Player

  def save_player_name(conn, %{"player_name_form" => %{"player_name" => name}}) do
    player = Plug.Conn.get_session(conn, "player")
    {:ok, player} = Player.merge_and_save(player.id, %{name: name})

    conn
    |> put_session("player", player)
    |> redirect(to: "/")
  end
end
