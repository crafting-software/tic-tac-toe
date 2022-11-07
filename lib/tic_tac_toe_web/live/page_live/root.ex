defmodule TicTacToeWeb.PageLive.Root do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Game.Engine

  def mount(_params, session, socket) do
    {
      :ok,
      assign(
        socket,
        %{
          player_id: session["player_id"]
        }
      )
    }
  end

  @impl true
  def handle_event("new-game", params, socket) do
    {:ok, {game_id, _}} = Engine.new_game(socket.assigns.player_id)

    {
      :noreply,
      push_redirect(socket, to: "/game/#{game_id}")
    }
  end
end
