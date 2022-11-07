defmodule TicTacToe.PubSub do
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(TicTacToe.PubSub, topic)
  end

  def broadcast({:error, _reason} = error, _topic, _event), do: error

  def broadcast({:ok, result}, topic, event) do
    Phoenix.PubSub.broadcast(TicTacToe.PubSub, topic, {event, result})
    {:ok, result}
  end
end
