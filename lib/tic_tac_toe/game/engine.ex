defmodule TicTacToe.Game.Engine do
  alias TicTacToe.Game.State
  alias TicTacToe.Storage
  alias TicTacToe.PubSub

  require Logger

  def new_game(owner) do
    state = %State{
      session_id: generate_session_id(),
      players: [owner, nil],
      active_player_idx: 0,
      turns: 0,
      state: :waiting,
      board: init_board()
    }

    :ets.insert(:game_sessions, {state.session_id, state})

    {:ok, {state.session_id, state}}
  end

  def active_player(%State{active_player_idx: idx, players: players}),
    do: Enum.at(players, idx)

  def join_game(game_id, joining_player) do
    case Storage.find_game_by_id(game_id) do
      {:ok, {_, %State{players: players} = state}} ->
        if not Enum.member?(players, joining_player) do
          players =
            Enum.map(players, fn
              nil -> joining_player
              player -> player
            end)

          new_state = %{state | players: players, state: :started}
          PubSub.broadcast(Storage.save_session(new_state), "game-state-updates", :player_joined)
        else
          {:ok, state}
        end

      {:error, _} = error ->
        error
    end
  end

  def put_symbol(
        current_player,
        %State{board: board, active_player_idx: active_player_idx, players: players, turns: turns} =
          state,
        {x, y} = _pos
      ) do
    with {:currently_active_player, active_player} when not is_nil(active_player) <-
           {:currently_active_player, Enum.at(players, active_player_idx)},
         {:is_current_player?, true} <- {:is_current_player?, current_player === active_player},
         {:row, row} when is_list(row) <- {:row, Enum.at(board, y)} do
      row =
        Enum.with_index(row, fn
          _el, ^x -> active_player_idx
          el, _ -> el
        end)

      board =
        Enum.with_index(board, fn
          _el, ^y -> row
          el, _ -> el
        end)

      {:ok, result} =
        %{state | board: board, turns: turns + 1}
        |> resolve_state()
        |> Storage.save_session()

      result
    else
      {:is_current_player?, false} ->
        state

      other ->
        Logger.warn("An error has occurred: #{inspect(other, pretty: true)}")
        state
    end
  end

  defp resolve_state(
         %State{board: board, turns: turns, active_player_idx: active_player_idx} = state
       ) do
    result =
      {:in_progress, board}
      |> resolve_rows()
      |> resolve_columns()
      |> resolve_diagonals()

    with {:result, {:in_progress, _board}} <- {:result, result},
         {:turns, 9} <- {:turns, turns} do
      new_state = %{state | state: {:finished, :draw}}
      PubSub.broadcast(new_state, "game-state-updates", :game_finished)
      new_state
    else
      # Case when less than 9 turns have passed and no player won.
      # This means that there are still empty cells on the board,
      # therefore the game can continue unless a player claims victory.
      {:turns, _} ->
        new_state = %{state | active_player_idx: rem(active_player_idx + 1, 2)}
        PubSub.broadcast(new_state, "game-state-updates", :player_turn_passed)
        new_state

      # Case when a player claims victory.
      {:result, {:finished, winner}} ->
        new_state = %{state | state: {:finished, winner}}
        PubSub.broadcast(new_state, "game-state-updates", :game_finished)
        new_state
    end
  end

  defp resolve_diagonals({:in_progress, board}) do
    case board do
      [[sym, _, _], [_, sym, _], [_, _, sym]] when not is_nil(sym) -> {:finished, sym}
      [[_, _, sym], [_, sym, _], [sym, _, _]] when not is_nil(sym) -> {:finished, sym}
      _ -> {:in_progress, board}
    end
  end

  defp resolve_diagonals({:finished, x}), do: {:finished, x}

  defp resolve_rows({:in_progress, board}) do
    case board do
      [[sym, sym, sym], _, _] when not is_nil(sym) -> {:finished, sym}
      [_, [sym, sym, sym], _] when not is_nil(sym) -> {:finished, sym}
      [_, _, [sym, sym, sym]] when not is_nil(sym) -> {:finished, sym}
      _ -> {:in_progress, board}
    end
  end

  defp resolve_rows({:finished, x}), do: {:finished, x}

  defp resolve_columns({:in_progress, board}) do
    case board do
      [[sym, _, _], [sym, _, _], [sym, _, _]] when not is_nil(sym) -> {:finished, sym}
      [[_, sym, _], [_, sym, _], [_, sym, _]] when not is_nil(sym) -> {:finished, sym}
      [[_, _, sym], [_, _, sym], [_, _, sym]] when not is_nil(sym) -> {:finished, sym}
      _ -> {:in_progress, board}
    end
  end

  defp resolve_columns({:finished, x}), do: {:finished, x}

  defp generate_session_id(),
    do:
      ?A..?Z
      |> Enum.take_random(5)
      |> Enum.map(&<<&1::utf8>>)
      |> Enum.join()

  defp init_board(), do: Enum.map(0..2, fn _ -> [nil, nil, nil] end)
end
