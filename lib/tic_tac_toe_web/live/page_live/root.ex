defmodule TicTacToeWeb.PageLive.Root do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Game.{Engine, Player}

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      assign(
        socket,
        %{
          player: %Player{
            id: session["player_id"],
            name: session["player_name"]
          },
          show_set_player_name_modal: false
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
  def handle_event("toggle-set-player-name-modal", _params, socket) do
    {
      :noreply,
      assign(socket, :show_set_player_name_modal, true)
    }
  end
end
