defmodule TicTacToe.Validation.Game do
  alias TicTacToe.Game.Session, as: GameSession

  @doc """
  Validates the format of the game_id.
  Must be A-Z only, 5 characters.
  """
  def validate_format({:ok, game_id}),
    do: validate_format(game_id)

  def validate_format({:error, msg}),
    do: {:error, msg}

  def validate_format(game_id) do
    with {:length, 5} <- {:length, String.length(game_id)},
         {:match_regex, true} <- {:match_regex, game_id =~ ~r/[A-Z]+/} do
      {:ok, game_id}
    else
      {_, _} ->
        {:error, "Invalid game ID"}
    end
  end

  @doc """
  Validates the join conditions for a game.
  """
  def validate_join({:ok, game_id}),
    do: validate_join(game_id)

  def validate_join({:error, msg}),
    do: {:error, msg}

  def validate_join(game_id) do
    with {:game, {:ok, {_, %GameSession{id: ^game_id, players: players}}}} <-
           {:game, GameSession.get_by_id(game_id)},
         {:can_join?, true} <- {:can_join?, Enum.member?(players, nil)} do
      {:ok, game_id}
    else
      {:game, {:error, :not_found}} -> {:error, "Game not found"}
      {:can_join?, false} -> {:error, "You cannot join this game"}
    end
  end
end
