defmodule TicTacToeWeb.GameView do
  use TicTacToeWeb, :view

  def game_status(%{
        player: %{id: id},
        game_session: %{players: players, active_player_idx: idx, state: {:finished, idx}}
      }) do
    current_player = Enum.at(players, idx)

    if current_player.id == id,
      do: "You won",
      else: "#{current_player.name} won"
  end

  def game_status(%{game_session: %{state: {:finished, :draw}}}),
    do: "It's a draw!"

  def game_status(%{
        player: %{id: id},
        game_session: %{players: players, active_player_idx: idx, state: :started}
      }) do
    current_player = Enum.at(players, idx)

    if current_player.id == id,
      do: "Your turn",
      else: "#{current_player.name}'s turn"
  end

  def game_status(%{game_session: %{state: :waiting}}),
    do: "Waiting for other player"
end
