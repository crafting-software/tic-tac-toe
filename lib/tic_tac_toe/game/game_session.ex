defmodule TicTacToe.Game.Session do
  alias TicTacToe.Game.Player
  alias TicTacToe.Storage

  defstruct [
    # The ID of the game session.
    id: nil,
    # List of joined players.
    player_ids: [nil, nil],
    # The player whose current turn is.
    active_player_idx: 0,
    # State of every cell of the board.
    board: [],
    # State of the game.
    state: nil,
    # Turns passed so far
    turns: 0,
    # Preloaded info about players. Do not save.
    players: [],
    # The ID of the associated challenge.
    challenge_id: nil
  ]

  @table :game_sessions

  def get_by_id(id),
    do: Storage.get_by_id(@table, id)

  def save(id, data),
    do: Storage.save(@table, {id, data})

  def load_player_data(%__MODULE__{player_ids: player_ids} = game) do
    players =
      player_ids
      |> Enum.reject(&is_nil/1)
      |> Enum.map(fn id ->
        {:ok, player} = Player.get_by_id(id)
        player
      end)

    Map.put(game, :players, players)
  end
end
