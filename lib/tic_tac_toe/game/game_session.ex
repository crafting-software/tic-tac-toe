defmodule TicTacToe.Game.Session do
  alias TicTacToe.Storage

  defstruct [
    # The ID of the game session.
    id: nil,
    # List of joined players.
    players: [nil, nil],
    # The player whose current turn is.
    active_player_idx: 0,
    # State of every cell of the board.
    board: [],
    # State of the game.
    state: nil,
    # Turns passed so far
    turns: 0
  ]

  @table :game_sessions

  def get_by_id(id),
    do: Storage.get_by_id(@table, id)

  def save(id, data),
    do: Storage.save(@table, {id, data})
end
