defmodule TicTacToe.Game.Stats do
  alias TicTacToe.Game.Session, as: GameSession
  alias TicTacToe.Game.Player

  defstruct wins: 0, losses: 0

  def get_stats(%Player{stats: %__MODULE__{} = stats}),
    do: stats

  def get_stats(%Player{stats: nil}),
    do: %__MODULE__{}

  def save(player_id, type) when type in [:win, :loss] do
    case Player.get_by_id(player_id) do
      {:ok, {_, %Player{} = player}} ->
        stats = get_stats(player)

        updated_stats =
          case type do
            :win -> %{stats | wins: stats.wins + 1}
            :loss -> %{stats | losses: stats.losses + 1}
          end

        Player.save(player_id, %{player | stats: updated_stats})

      {:error, error} ->
        {:error, error}
    end
  end

  def update(%GameSession{players: players, state: {:finished, winner_idx}}) do
    Enum.with_index(players, fn player, idx ->
      status =
        if idx == winner_idx,
          do: :win,
          else: :loss

      save(player.id, status)
    end)

    :ok
  end
end
