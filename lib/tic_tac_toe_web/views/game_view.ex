defmodule TicTacToeWeb.GameView do
  use TicTacToeWeb, :view

  def game_status(%{
        player: %{id: id},
        game_session: %{players: players, active_player_idx: idx, state: {:finished, idx}}
      }), do:
    %{
      current_player: Enum.at(players, idx),
      opponent: Enum.find(players, fn player -> player.id != id end),
      state: :finished
    }

  def game_status(%{
        player: %{id: id},
        game_session: %{players: players, active_player_idx: idx, state: {:finished, :draw}}
      }), do:
    %{
      current_player: Enum.at(players, idx),
      opponent: Enum.find(players, fn player -> player.id != id end),
      state: :draw
    }

  def game_status(%{
        player: %{id: id},
        game_session: %{players: players, active_player_idx: idx, state: :started}
      }), do:
    %{
      current_player: Enum.at(players, idx),
      opponent: Enum.find(players, fn player -> player.id != id end) |> IO.inspect(label: :opponent),
      state: :playing
    }

  def game_status(%{game_session: %{state: :waiting}}),
    do: "Waiting for other player"
end
