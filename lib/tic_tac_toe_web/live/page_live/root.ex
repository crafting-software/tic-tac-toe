defmodule TicTacToeWeb.PageLive.Root do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Game.{Engine, Player}
  alias TicTacToeWeb.PageLive.{SetPlayerNameModal, JoinGameModal}

  @impl true
  def mount(_params, %{"player" => %Player{id: _, name: player_name} = player}, socket) do
    {
      :ok,
      assign(
        socket,
        %{
          player: player,
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
  def handle_event("new-game", _params, socket) do
    {:ok, {game_id, _}} = Engine.new_game(socket.assigns.player)

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
end
