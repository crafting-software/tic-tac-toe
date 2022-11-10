defmodule TicTacToeWeb.PlayerNameController do
  use TicTacToeWeb, :controller

  def save_player_name(conn, %{"player_name_form" => %{"player_name" => name}}) do
    conn
    |> put_session("player_name", name)
    |> redirect(to: "/")
  end
end
