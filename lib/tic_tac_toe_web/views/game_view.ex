defmodule TicTacToeWeb.GameView do
  use TicTacToeWeb, :view

  def game_status(%{
        player_id: player_id,
        game_session: %{players: players, active_player_idx: idx, state: {:finished, idx}}
      }) do
    if Enum.at(players, idx) == player_id,
      do: "You won",
      else: "Your opponent won"
  end

  def game_status(%{game_session: %{state: {:finished, :draw}}}),
    do: "It's a draw!"

  def game_status(%{
        player_id: player_id,
        game_session: %{players: players, active_player_idx: idx, state: :started}
      }) do
    if Enum.at(players, idx) == player_id,
      do: "Your turn",
      else: "Your opponent's turn"
  end

  def game_status(%{game_session: %{state: :waiting}}),
    do: "Waiting for other player"
end
