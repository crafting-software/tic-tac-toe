defmodule TicTacToeWeb.PageLive.Root do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Game.{Engine, Player, Session, Challenge}
  alias TicTacToe.PubSub
  alias TicTacToeWeb.PageLive.{SetPlayerNameModal, JoinGameModal}
  alias TicTacToeWeb.SessionUtils

  @impl true
  def mount(_params, %{"player" => %Player{id: id, name: player_name} = player}, socket) do
    {:ok, player} = Player.merge_and_save(id, SessionUtils.to_user_session_params(player))

    if connected?(socket) do
      PubSub.subscribe("leaderboard-updates")
      PubSub.subscribe("player-challenges:#{id}")
      PubSub.subscribe("player-updates")
    end

    {
      :ok,
      assign(
        socket,
        %{
          player: player,
          leaderboard_players: Player.get_leaderboard_players(),
          challenges: get_personal_challenges(id),
          modal_component:
            if(is_nil(player_name),
              do: {SetPlayerNameModal, %{player_name: player_name}},
              else: {nil, %{}}
            )
        }
      )
    }
  end

  @impl true
  def handle_info({:leaderboard_update, _}, socket) do
    {:noreply, assign(socket, :leaderboard_players, Player.get_leaderboard_players())}
  end

  @impl true
  def handle_info({:name_set, player}, socket) do
    %Player{id: player_id, name: _player_name} = player
    %{leaderboard_players: leaderboard, challenges: challenges} = socket.assigns

    {
      :noreply,
      assign(
        socket,
        %{
          leaderboard_players:
            [player | leaderboard]
            |> Enum.uniq_by(& &1.id)
            |> Enum.sort_by(&(&1.stats.losses - &1.stats.wins)),
          challenges:
            Enum.map(challenges, fn challenge ->
              case challenge do
                %{issuer: %{id: ^player_id}} = challenge ->
                  %{challenge | issuer: player}

                %{opponent: %{id: ^player_id}} = challenge ->
                  %{challenge | opponent: player}

                other ->
                  other
              end
            end)
        }
      )
    }
  end

  @impl true
  def handle_info({:challenge_issued, challenge}, socket) do
    {:noreply, assign(socket, :challenges, [challenge | socket.assigns.challenges])}
  end

  @impl true
  def handle_event("new-game", _params, socket) do
    {:ok, %Session{id: game_id}} = Engine.new_game(socket.assigns.player.id)

    {
      :noreply,
      push_redirect(socket, to: "/game/#{game_id}")
    }
  end

  @impl true
  def handle_event("show-set-player-name-modal", _params, socket) do
    {
      :noreply,
      assign(
        socket,
        :modal_component,
        {SetPlayerNameModal, %{player_name: socket.assigns.player.name}}
      )
    }
  end

  @impl true
  def handle_event("show-join-game-modal", _params, socket) do
    {
      :noreply,
      assign(
        socket,
        :modal_component,
        {JoinGameModal, %{game_id: nil, id: "join-game-form", error: nil}}
      )
    }
  end

  @impl true
  def handle_event("dismiss-modal", _, socket) do
    {
      :noreply,
      assign(
        socket,
        :modal_component,
        {nil, %{}}
      )
    }
  end

  @impl true
  def handle_event("issue-challenge", %{"opponent-id" => opponent_id}, socket) do
    current_player_id = socket.assigns.player.id

    {:ok, %Challenge{id: _challenge_id} = challenge} =
      Challenge.create({current_player_id, opponent_id})

    {
      :noreply,
      assign(socket, :challenges, [challenge | socket.assigns.challenges])
    }
  end

  @impl true
  def handle_event(
        "join-challenge",
        %{"game-id" => game_id, "challenge-id" => challenge_id},
        socket
      ) do
    {:noreply, push_redirect(socket, to: "/game/#{game_id}?challenge_id=#{challenge_id}")}
  end

  defp get_personal_challenges(current_player_id),
    do:
      Challenge.get_all(fn %Challenge{
                             issuer_id: challenge_issuer_id,
                             opponent_id: challenge_opponent_id
                           } ->
        challenge_issuer_id == current_player_id or challenge_opponent_id == current_player_id
      end)
end
