defmodule TicTacToe.Storage do
  @tables [
    {:game_sessions, :set}
  ]

  def init_tables(),
    do:
      Enum.each(@tables, fn {table, type} ->
        :ets.new(table, [type, :public, :named_table])
      end)

  def find_game_by_id(game_id) do
    case :ets.lookup(:game_sessions, game_id) do
      [game] -> {:ok, game}
      [] -> {:error, :not_found}
    end
  end

  def save_session(session) do
    case :ets.insert(:game_sessions, {session.session_id, session}) do
      true -> {:ok, session}
      _ -> :error
    end
  end
end
