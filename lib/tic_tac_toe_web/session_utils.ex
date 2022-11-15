defmodule TicTacToeWeb.SessionUtils do
  import Plug.Conn, only: [get_session: 1, put_session: 3]
  alias TicTacToe.Game.Player

  def maybe_create_user_session(conn, _opts) do
    session = get_session(conn)

    case session do
      %{"player" => %{id: player_id}} when not is_nil(player_id) ->
        conn

      %{} ->
        put_session(conn, "player", %Player{id: UUID.uuid4()})
    end
  end
end
