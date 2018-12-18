defmodule Lumber do
  
end

defmodule Day18 do
  @moduledoc """
  Documentation for Day18.
  """

  @doc """
      iex> Day18.lumber(".#.#...|#.
      ...> .....#|##|
      ...> .|..|...#.
      ...> ..|#.....#
      ...> #.#|||#|#|
      ...> ...#.||...
      ...> .|....|...
      ...> ||...#|.#|
      ...> |.||||..|.
      ...> ...#.|..|.")
      :world
"""
  def lumber(input) do
    input
    |> String.split("\n")
  end
end
