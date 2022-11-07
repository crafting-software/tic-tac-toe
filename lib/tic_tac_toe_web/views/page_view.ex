defmodule TicTacToeWeb.PageView do
  use TicTacToeWeb, :view

  def symbol_for_player(nil), do: ""

  def symbol_for_player(index),
    do:
      ["&#10005;", "&#9711;"]
      |> Enum.at(index)
      |> Phoenix.HTML.raw()

  def render_board(board) do
    board
    |> List.flatten()
    |> Enum.map(&symbol_for_player/1)
  end
end
