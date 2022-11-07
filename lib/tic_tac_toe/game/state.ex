defmodule TicTacToe.Game.State do
  defstruct [
    # The ID of the game session.
    session_id: nil,
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
end
