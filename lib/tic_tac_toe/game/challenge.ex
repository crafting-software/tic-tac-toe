defmodule TicTacToe.Game.Challenge do
  alias TicTacToe.Game.Engine
  alias TicTacToe.PubSub
  alias TicTacToe.Game.{Player, Session}
  alias TicTacToe.Storage

  defstruct [
    :id,
    :issuer_id,
    :opponent_id,
    :inserted_at,
    :game_id,
    status: :pending
  ]

  @table :challenges

  defp now(),
    do:
      DateTime.utc_now()
      |> DateTime.to_unix()

  defp save(id, data),
    do:
      @table
      |> Storage.save({id, data})
      |> load_player_info()

  def create({issuer_id, opponent_id}) do
    challenge_id = UUID.uuid4()

    {:ok, %{id: game_id}} = Engine.new_game(issuer_id, opponent_id, challenge_id)

    challenge = %__MODULE__{
      id: challenge_id,
      issuer_id: issuer_id,
      opponent_id: opponent_id,
      inserted_at: now(),
      game_id: game_id
    }

    {:ok, result} = save(challenge_id, challenge)
    # {:ok, %Session{id: _game_id}} = Session.save(UUID.uuid4(), %Session{
    #   players: [],
    #   challenge_id: challenge_id
    # })
    PubSub.broadcast(result, "player-challenges:#{opponent_id}", :challenge_issued)
    {:ok, result}
  end

  def get_by_id(id),
    do: Storage.get_by_id(@table, id)

  def merge_and_save(id, data) do
    case get_by_id(id) do
      {:ok, challenge} ->
        updated_challenge = Map.merge(challenge, data)
        save(@table, {challenge.id, updated_challenge})

      {:error, :not_found} ->
        {:error, :challenge_not_found}
    end
  end

  def get_all(filter \\ fn _ -> true end),
    do:
      @table
      |> Storage.get_all()
      |> Enum.filter(filter)
      |> load_player_info()

  def load_player_info(challenges) when is_list(challenges) do
    player_ids =
      Enum.reduce(challenges, [], fn %__MODULE__{issuer_id: issuer_id, opponent_id: opponent_id},
                                     acc ->
        [issuer_id | [opponent_id | acc]]
      end)
      |> Enum.uniq()

    players = Player.get_all(fn %{id: id} -> id in player_ids end)

    Enum.map(challenges, fn %__MODULE__{} = challenge ->
      issuer = Enum.find(players, fn %{id: player_id} -> player_id == challenge.issuer_id end)
      opponent = Enum.find(players, fn %{id: player_id} -> player_id == challenge.opponent_id end)

      Map.merge(challenge, %{issuer: issuer, opponent: opponent})
    end)
  end

  def load_player_info(%__MODULE__{issuer_id: issuer_id, opponent_id: opponent_id} = challenge) do
    {:ok, issuer} = Player.get_by_id(issuer_id)
    {:ok, opponent} = Player.get_by_id(opponent_id)

    Map.merge(challenge, %{issuer: issuer, opponent: opponent})
  end

  def load_player_info({:ok, data}), do: {:ok, load_player_info(data)}

  def update_challenge_status(nil, _), do: {:ok, nil}

  def update_challenge_status(challenge_id, winner) do
    {:ok, challenge} = get_by_id(challenge_id)

    updated_challenge =
      case winner do
        nil -> %{challenge | status: {:finished, :draw}}
        winner -> %{challenge | status: {:finished, winner}}
      end

    save(updated_challenge.id, updated_challenge)
  end

  # defp challenge_save_params(%__MODULE__{} = challenge),
  #   do: %{challenge | issuer: nil, opponent: nil}
end
