defmodule TicTacToeWeb.PlayerNameController do
  use TicTacToeWeb, :controller

  alias TicTacToe.PubSub
  alias TicTacToe.Game.Player

  def save_player_name(conn, %{"player_name_form" => %{"player_name" => name}}) do
    player = Plug.Conn.get_session(conn, "player")
    {:ok, player} = Player.merge_and_save(player.id, %{name: name})

    PubSub.broadcast(player, "player-updates", :name_set)

    conn
    |> put_session("player", player)
    |> redirect(to: "/")
  end
end
