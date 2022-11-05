defmodule TicTacToeWeb.PageLive.Root do
  use TicTacToeWeb, :live_view

  def mount(_params, session, socket) do
    {
      :ok,
      assign(
        socket,
        %{
          player_name: session["player_name"]
        }
      )
    }
  end
end
