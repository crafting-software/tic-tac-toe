defmodule TicTacToeWeb.PlayerNameController do
  use TicTacToeWeb, :controller

  def save_player_name(conn, %{"player_name_form" => %{"player_name" => name}}) do
    player = Plug.Conn.get_session(conn, "player") |> IO.inspect()

    conn
    |> put_session("player", %{player | name: name})
    |> redirect(to: "/")
  end
end
