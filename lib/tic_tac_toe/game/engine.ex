defmodule TicTacToe.Game.Engine do
  alias TicTacToe.Game.Challenge
  alias TicTacToe.Game.Session, as: GameSession
  alias TicTacToe.Game.{Player, Stats}
  alias TicTacToe.PubSub

  require Logger

  def new_game(owner) do
    state = %GameSession{
      id: generate_new_game_id(),
      player_ids: [owner, nil],
      active_player_idx: 0,
      turns: 0,
      state: :waiting,
      board: init_board()
    }

    GameSession.save(state.id, state)
  end

  def new_game(owner, other_player, challenge_id) do
    state = %GameSession{
      id: generate_new_game_id(),
      player_ids: [owner, other_player],
      active_player_idx: 0,
      turns: 0,
      state: :started,
      board: init_board(),
      challenge_id: challenge_id
    }

    GameSession.save(state.id, state)
  end

  def active_player(%GameSession{active_player_idx: idx, player_ids: player_ids}),
    do: Enum.at(player_ids, idx)

  def join_game(game_id, joining_player) do
    case GameSession.get_by_id(game_id) do
      {:ok, %GameSession{player_ids: player_ids} = state} ->
        if not Enum.member?(player_ids, joining_player) do
          player_ids =
            Enum.map(player_ids, fn
              nil -> joining_player
              player -> player
            end)

          {:ok, new_state} =
            GameSession.save(game_id, %{state | player_ids: player_ids, state: :started})

          new_state = GameSession.load_player_data(new_state)

          PubSub.broadcast(
            new_state,
            "game-state-updates:#{game_id}",
            :player_joined
          )
        else
          {:ok, state}
        end

      {:error, _} = error ->
        error
    end
  end

  def put_symbol(
        current_player,
        %GameSession{
          id: game_id,
          board: board,
          active_player_idx: active_player_idx,
          player_ids: player_ids,
          turns: turns
        } = state,
        {x, y} = _pos
      ) do
    with {:currently_active_player, active_player} when not is_nil(active_player) <-
           {:currently_active_player, Enum.at(player_ids, active_player_idx)},
         {:is_current_player?, true} <-
           {:is_current_player?, current_player === active_player},
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
        GameSession.save(game_id, resolve_state(%{state | board: board, turns: turns + 1}))

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
         %GameSession{
           id: game_id,
           board: board,
           turns: turns,
           challenge_id: challenge_id,
           active_player_idx: active_player_idx
         } = state
       ) do
    result =
      {:in_progress, board}
      |> resolve_rows()
      |> resolve_columns()
      |> resolve_diagonals()

    with {:result, {:in_progress, _board}} <- {:result, result},
         {:turns, 9} <- {:turns, turns} do
      new_state = %{state | state: {:finished, :draw}}
      Challenge.update_challenge_status(challenge_id, nil)
      PubSub.broadcast(new_state, "game-state-updates:#{game_id}", :game_finished)
      new_state
    else
      # Case when less than 9 turns have passed and no player won.
      # This means that there are still empty cells on the board,
      # therefore the game can continue unless a player claims victory.
      {:turns, _} ->
        new_state = %{state | active_player_idx: rem(active_player_idx + 1, 2)}
        PubSub.broadcast(new_state, "game-state-updates:#{game_id}", :player_turn_passed)
        new_state

      # Case when a player claims victory.
      {:result, {:finished, winner_idx}} ->
        new_state = %{state | state: {:finished, winner_idx}}
        Stats.update(new_state)
        Challenge.update_challenge_status(challenge_id, active_player(new_state))
        PubSub.broadcast(new_state, "game-state-updates:#{game_id}", :game_finished)
        PubSub.broadcast([], "leaderboard-updates", :leaderboard_update)
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

  defp generate_new_game_id(),
    do:
      ?A..?Z
      |> Enum.take_random(5)
      |> Enum.map(&<<&1::utf8>>)
      |> Enum.join()

  defp init_board(), do: Enum.map(0..2, fn _ -> [nil, nil, nil] end)
end
