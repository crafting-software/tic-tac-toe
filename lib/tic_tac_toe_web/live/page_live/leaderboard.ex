defmodule TicTacToeWeb.PageLive.Leaderboard do
  use TicTacToeWeb, :live_component

  def render(assigns) do
    ~H"""
      <table class="mx-auto">
        <thead>
          <tr>
            <th class="px-1">Place</th>
            <th class="px-1">Name</th>
            <th class="px-1">Wins</th>
            <th class="px-1">Losses</th>
            <th class="px-1">Challenge</th>
          </tr>
        </thead>

        <tbody>
          <%= for {player, idx} <- Enum.with_index(@leaderboard_players) do %>
            <tr class={if player.id == @player.id, do: "bg-green-400"}>
              <td><%= idx + 1 %></td>
              <td><%= player.name %></td>
              <td><%= player.stats.wins %></td>
              <td><%= player.stats.losses %></td>
              <td>
                <%= if can_challenge?(@player.id, player.id, @challenges) do %>
                  <a href="#" phx-click="issue-challenge" phx-value-opponent-id={player.id}>[x]</a>
                <% end %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
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
