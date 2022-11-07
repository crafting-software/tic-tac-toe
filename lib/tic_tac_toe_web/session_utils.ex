defmodule TicTacToeWeb.SessionUtils do
  import Plug.Conn, only: [get_session: 1, put_session: 3]

  def maybe_create_user_session(conn, _opts) do
    session = get_session(conn)

    case session do
      %{"player_id" => player_id} when not is_nil(player_id) ->
        conn

      %{} ->
        put_session(conn, "player_id", UUID.uuid4())
    end
  end
end
