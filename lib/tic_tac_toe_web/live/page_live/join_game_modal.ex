defmodule TicTacToeWeb.PageLive.JoinGameModal do
  use TicTacToeWeb, :live_component

  import TicTacToe.Validation.Game

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <div class="bg-black fixed w-screen top-0 opacity-60 h-screen"></div>

      <div class="absolute top-1/4 w-screen">
        <div class="bg-white w-96 mx-auto p-5">
          <h1 class="text-xl text-indigo-600 mx-auto font-bold py-5 text-center">Join Game</h1>
          <%= f = form_for :join_game_form, "#",
            class: "flex flex-col",
            phx_submit: "try-join-game",
            phx_change: "validate-game-id",
            phx_target: @myself %>
            <%= text_input f, :game_id, value: assigns.game_id, placeholder: "Game ID", class: "my-5" %>
            <p class="text-red-400"><%= @error %></p>
            <%= submit "JOIN", class: "items-center my-5 justify-center rounded-md border border-transparent bg-indigo-600 px-8 py-3 text-base text-white hover:bg-indigo-700 md:py-4 md:px-10 md:text-lg", disabled: !!@error %>

            <a href="#" class="justify-center rounded-md border border-transparent bg-indigo-100 px-8 py-3 text-center font-medium text-indigo-700 hover:bg-indigo-200 md:py-4 md:px-10 md:text-lg" phx-click="dismiss-modal">CANCEL</a>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate-game-id", %{"join_game_form" => %{"game_id" => game_id}}, socket) do
    case validate_format(game_id) do
      {:ok, _} ->
        {:noreply, assign(socket, error: nil)}

      {:error, msg} ->
        {
          :noreply,
          assign(socket, error: msg)
        }
    end
  end

  @impl true
  def handle_event("try-join-game", %{"join_game_form" => %{"game_id" => game_id}}, socket) do
    case validate(game_id) do
      {:ok, _} ->
        {
          :noreply,
          socket
          |> assign(:error, nil)
          |> push_redirect(to: "/game/#{game_id}")
        }

      {:error, msg} ->
        {
          :noreply,
          assign(socket, error: msg)
        }
    end
  end

  defp validate(game_id),
    do:
      game_id
      |> validate_format()
      |> validate_join()
end
