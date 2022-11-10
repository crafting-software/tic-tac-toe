defmodule TicTacToeWeb.PageLive.SetPlayerNameModal do
  use TicTacToeWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="bg-black fixed w-screen top-0 opacity-60 h-screen"></div>

      <div class="absolute top-1/4 w-screen">
        <div class="bg-white w-96 mx-auto">
          <h1 class="text-xl text-indigo-600 font-bold px-10 py-5 text-center">Welcome!</h1>
          <p class="text-center">Please set your player name.</p>
          <%= f = form_for :player_name_form, "/", method: :post,
            id: "player-name-form",
            class: "flex flex-col px-5"%>

            <%= text_input f, :player_name, value: assigns.player_name, placeholder: "Type your player name", class: "my-5" %>

            <%= submit "OK", class: "items-center my-5 justify-center rounded-md border border-transparent bg-indigo-600 px-8 py-3 text-base text-white hover:bg-indigo-700 md:py-4 md:px-10 md:text-lg" %>
        </div>
      </div>
    </div>
    """
  end
end
