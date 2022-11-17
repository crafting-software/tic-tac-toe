defmodule TicTacToe.Storage do
  @tables [
    {:game_sessions, :set},
    {:players, :set}
  ]

  def init_tables(),
    do:
      Enum.each(@tables, fn {table, type} ->
        :ets.new(table, [type, :public, :named_table])
      end)

  def get_by_id(table, id) do
    case :ets.lookup(table, id) do
      [entity] -> {:ok, entity}
      [] -> {:error, :not_found}
    end
  end

  def save(table, {id, data}) do
    case :ets.insert(table, {id, data}) do
      true -> {:ok, data}
      _ -> :error
    end
  end

  def get_all(table, pattern \\ :"$1"),
    do: List.flatten(:ets.match(table, pattern))
end
