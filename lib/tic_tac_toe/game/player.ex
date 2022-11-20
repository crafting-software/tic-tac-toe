defmodule TicTacToe.Game.Player do
  alias TicTacToe.Storage
  alias TicTacToe.Game.Stats

  defstruct [:name, :id, :stats]

  @table :players

  def get_by_id(id),
    do: Storage.get_by_id(@table, id)

  def save(data),
    do: Storage.save(@table, {UUID.uuid4(), data})

  def save(id, data),
    do: Storage.save(@table, {id, data})

  def merge_and_save(id, data) do
    case get_by_id(id) do
      {:ok, player} ->
        updated_player = Map.merge(player, data)
        save(id, updated_player)

      {:error, :not_found} ->
        save(id, Map.put(struct(__MODULE__, data), :stats, %Stats{}))
    end
  end

  def get_all(filter \\ fn _ -> true end),
    do:
      @table
      |> Storage.get_all()
      |> Enum.filter(filter)
      |> Enum.map(fn entry ->
        %{entry | stats: Stats.get_stats(entry)}
      end)

  def get_leaderboard_players(),
    do:
      get_all()
      |> Enum.filter(fn %{name: name} -> not is_nil(name) end)
      |> Enum.sort_by(fn %{stats: %{wins: wins, losses: losses}} ->
        losses - wins
      end)
end
