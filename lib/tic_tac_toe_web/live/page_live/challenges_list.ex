defmodule TicTacToeWeb.PageLive.ChallengesList do
  use TicTacToeWeb, :live_component

  def render(assigns) do
    ~H"""
      <table class="mx-auto">
        <thead>
          <tr>
            <th class="px-1">Challenge</th>
            <th class="px-1">Game Status</th>
          </tr>
        </thead>

        <tbody>
          <%= for challenge <- @challenges do %>
            <tr>
              <td>
                <%= if challenge.issuer_id == @player.id do %>
                  You challenged <span class="font-bold text-indigo-600"><%= challenge.opponent.name %></span>
                <% else %>
                  <span class="font-bold text-indigo-600"><%= challenge.issuer.name %></span> challenged you
                <% end %>
              </td>
              <td>
                <%= case challenge.status do %>
                  <% :pending -> %>
                    <a href="#" phx-click="join-challenge" phx-value-game-id={challenge.game_id} phx-value-challenge-id={challenge.id} class="text-indigo-600">Play</a>
                  <% {:finished, :draw} -> %>
                    <span class="font-bold text-yellow-500">Draw</span>
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
    """
  end
end
