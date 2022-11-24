defmodule TicTacToeWeb.PageLive.ChallengesList do
  use TicTacToeWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="mx-auto lg:w-4/12 md:w-full sm:w-full p-4 bg-white border rounded-lg shadow-md sm:p-8 dark:bg-gray-800 dark:border-gray-700">
          <div class="flex items-center justify-between mb-4">
              <h5 class="mx-auto text-xl font-bold leading-none text-gray-900 dark:text-white">My Challenges</h5>
        </div>
        <div class="flow-root">
          <table class="w-full mx-auto text-sm text-left text-gray-500 dark:text-gray-400">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
              <tr>
                <th class="py-3 px-6">Challenge</th>
                <th class="py-3 px-6">Game Status</th>
              </tr>
            </thead>

            <tbody class="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
              <%= for challenge <- @challenges do %>
                <tr>
                  <td class="py-4 px-6">
                    <%= if challenge.issuer_id == @player.id do %>
                      You challenged <span class="font-bold text-indigo-600"><%= challenge.opponent.name %></span>
                    <% else %>
                      <span class="font-bold text-indigo-600"><%= challenge.issuer.name %></span> challenged you
                    <% end %>
                  </td>
                  <td class="py-4 px-6">
                    <%= case challenge.status do %>
                      <% :pending -> %>
                        <a href="#" phx-click="join-challenge" phx-value-game-id={challenge.game_id} phx-value-challenge-id={challenge.id} class="items-center justify-center rounded-md border border-transparent bg-indigo-600 px-2 py-1 text-base font-medium text-white hover:bg-indigo-700 md:py-1 md:px-3 md:text-sm">Play</a>
                      <% {:finished, :draw} -> %>
                        <span class="font-bold text-yellow-600">Draw</span>
                      <% {:finished, winner} -> %>
                        <%= if winner == @player.id do %>
                          <span class="font-bold text-green-600">Win</span>
                        <% else %>
                          <span class="font-bold text-red-600">Lose</span>
                        <% end %>
                    <% end %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>

    """
  end
end
