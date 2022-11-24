defmodule TicTacToeWeb.PageLive.Leaderboard do
  use TicTacToeWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="mx-auto lg:w-4/12 md:w-full sm:w-full p-4 bg-white border rounded-lg shadow-md sm:p-8 dark:bg-gray-800 dark:border-gray-700">
          <div class="flex items-center justify-between mb-4">
              <h5 class="mx-auto text-xl font-bold leading-none text-gray-900 dark:text-white">Leaderbord</h5>
        </div>
        <div class="flow-root">
          <table class="w-full mx-auto text-sm text-left text-gray-500 dark:text-gray-400">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
              <tr>
                <th scope="col" class="py-3 px-6">Place</th>
                <th scope="col" class="py-3 px-6">Name</th>
                <th scope="col" class="py-3 px-6"><span class="text-green-600">W</span>/<span class="text-red-600">L</span></th>
                <th scope="col" class="py-3 px-6"></th>
              </tr>
            </thead>

            <tbody class="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
              <%= for {player, idx} <- Enum.with_index(@leaderboard_players) do %>
                <tr class={if player.id == @player.id, do: "bg-green-100"}>
                  <th scope="row" class="py-4 px-6 font-medium text-gray-900 whitespace-nowrap dark:text-white"><%= idx + 1 %></th>
                  <td class="py-4 px-6">
                    <%= if @player.id == player.id do %>
                    <b>You</b>
                    <% else %>
                    <%= player.name %>
                    <% end %>
                  </td>
                  <td class="py-4 px-6"><span class="text-green-600"><%= player.stats.wins %></span>/<span class="text-red-600"><%= player.stats.losses %></span></td>
                  <td class="py-4 px-6">
                    <%= if can_challenge?(@player.id, player.id, @challenges) do %>
                      <a href="#" class="items-center justify-center rounded-md border border-transparent bg-indigo-600 px-2 py-1 text-base font-medium text-white hover:bg-indigo-700 md:py-1 md:px-3 md:text-sm" phx-click="issue-challenge" phx-value-opponent-id={player.id}>Challenge</a>
                    <% else %>
                      <%= if @player.id != player.id do %>
                      <span class="items-center justify-center rounded-md border border-transparent bg-gray-300 px-2 py-1 text-base font-medium text-white md:py-1 md:px-3 md:text-sm">Challenge</span>
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

  defp can_challenge?(player_id, player_id, _), do: false

  defp can_challenge?(_, _, []), do: true

  defp can_challenge?(player_id, opponent_id, challenges) do
    not Enum.any?(challenges, fn challenge ->
      challenge.status == :pending and
        (challenge.issuer_id in [player_id, opponent_id] and
           challenge.opponent_id in [player_id, opponent_id])
    end)
  end
end
