defmodule Lumber do
  defstruct field: [],
    generation: 0,
    dimension: 0
    
  def new(string) when is_binary(string) do
    field = 
    string
    |> String.split("\n", trim: true)
    |> Enum.map(&pad_line/1)
    |> Enum.map(&String.to_charlist/1)
    |> pad_field()
    
    length = length(hd(field))

    %__MODULE__{
      field: field,
      generation: 0,
      dimension: length - 2
    }
  end
  
  defp padding(n), do: padding(n, []) 
  defp padding(0, acc), do: acc
  defp padding(n, acc), do: padding(n-1, [?. | acc])

  defp pad_line(line), do: <<".", line::binary, ".">>
  defp pad_field(field) do  
    length = length(hd(field))
    empty = padding(length)
    
    [empty | 
      [empty | Enum.reverse(field)] 
      |>Enum.reverse()]
  end 
  
  def step(%__MODULE__{field: field, generation: generation, dimension: dimension}) do
    field = step(field, [])

    %__MODULE__{
      field: field,
      generation: generation+1,
      dimension: dimension
    }
  end
  
  defp step([[]], acc), do: acc
  defp step(field, acc) do
    field
  end   
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
    Lumber.new(input)
  end
end
