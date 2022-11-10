defmodule TicTacToeWeb.PageLive.Game do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Storage
  alias TicTacToe.Game.{Engine, Player}
  alias TicTacToe.PubSub

  @impl true
  def mount(
        %{"game_id" => game_id},
        %{"player_id" => player_id, "player_name" => player_name},
        socket
      ) do
    if connected?(socket), do: PubSub.subscribe("game-state-updates")

    player = %Player{id: player_id, name: player_name}

    case Storage.find_game_by_id(game_id) do
      {:ok, {_game_session_id, game}} ->
        Engine.join_game(game_id, player)

        {
          :ok,
          assign(socket, %{
            game_session: game,
            player: player
          })
        }

      _ ->
        # TODO: Handle case when game is not found.
        {:ok, socket}
    end
  end

  @impl true
  def handle_info({:player_joined, state}, socket) do
    {:noreply, assign(socket, :game_session, state)}
  end

  @impl true
  def handle_info({:player_turn_passed, state}, socket) do
    {:noreply, assign(socket, :game_session, state)}
  end

  @impl true
  def handle_info({:game_finished, state}, socket) do
    {:noreply, assign(socket, :game_session, state)}
  end

  @impl true
  def handle_event("maybe-select-cell", %{"x" => x, "y" => y}, socket) do
    [x, y] = Enum.map([x, y], &String.to_integer/1)
    game_state = socket.assigns.game_session
    player = socket.assigns.player

    if game_state.state == :started do
      new_game_state = Engine.put_symbol(player, game_state, {x, y})
      {:noreply, assign(socket, :game_session, new_game_state)}
    else
      {:noreply, socket}
    end
  end
end
