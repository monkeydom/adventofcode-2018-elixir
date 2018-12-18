defmodule Plant do
  defstruct state: "",
            left_index: 0,
            generation: 0

  def at(%__MODULE__{state: state, left_index: left_index}, index) do
    at(state, index - left_index)
  end

  @doc """
      iex> p = Plant.new("#..#.#..##......###...###")
      iex> Plant.at(p, 0)
      "#" 
      iex> Plant.at(p, -2)
      "." 
      iex> Plant.at(p, 5)
      "#" 
  """

  def at(<<>>, _), do: "."
  def at(b, n) when is_binary(b) and is_integer(n) and n < 0, do: "."
  def at(<<h, _::binary>>, 0), do: <<h>>
  def at(<<_, rest::binary>>, index), do: at(rest, index - 1)

  @doc """
      iex> Plant.new("#..#.#..##......###...###")
      %Plant{
              generation: 0,
              left_index: 0,
              state: "#..#.#..##......###...###"
            }

      iex> p = Plant.new("#..#.#..##......###...###")
      iex> Plant.seed_state_at(p, 1)
      ".#..#"
  """

  # inefficient, but hey, this time it doesn't seem relevant™
  def seed_state_at(p, index) do
    <<at(p, index - 2)::binary, at(p, index - 1)::binary, at(p, index)::binary,
      at(p, index + 1)::binary, at(p, index + 2)::binary>>
  end

  def new(binary, left_index \\ 0, generation \\ 0) when is_binary(binary) do
    slim(%__MODULE__{
      state: String.trim_trailing(binary, "."),
      left_index: left_index,
      generation: generation
    })
  end

  def slim(%__MODULE__{
        state: <<".", rest::binary>>,
        left_index: left_index,
        generation: generation
      }) do
    slim(%__MODULE__{state: rest, left_index: left_index + 1, generation: generation})
  end

  def slim(%__MODULE__{} = plant), do: plant

  def to_string(%__MODULE__{state: state, left_index: left_index, generation: generation}) do
    Enum.join(
      [
        "  ",
        -1..left_index |> Enum.map(fn _ -> "-" end) |> Enum.join(""),
        "0 - g: #{generation}",
        "\n",
        "  ",
        state,
        "\n"
      ],
      ""
    )
  end

  def sum(%__MODULE__{state: state, left_index: left_index}) do
    sum(state, left_index, 0)
  end

  defp sum(<<"#", rest::binary>>, left_index, acc),
    do: sum(rest, left_index + 1, acc + left_index)

  defp sum(<<_, rest::binary>>, left_index, acc), do: sum(rest, left_index + 1, acc)
  defp sum(<<>>, _, acc), do: acc
end

defmodule Day12 do
  @moduledoc """
  Documentation for Day12.
  """

  @doc """
      iex> result = Day12.generation("#..#.#..##......###...###", 20, MapSet.new(["...##",
      ...> "..#..",
      ...> ".#...",
      ...> ".#.#.",
      ...> ".#.##",
      ...> ".##..",
      ...> ".####",
      ...> "#.#.#",
      ...> "#.###",
      ...> "##.#.",
      ...> "##.##",
      ...> "###..",
      ...> "###.#",
      ...> "####."]))
      %Plant{
        generation: 20,
        left_index: -2,
        state: "#....##....#####...#######....#.#..##"
      }
      iex> Plant.sum(result)
      325
      
  """

  def generation(start, target, growset) when is_binary(start) do
    Plant.new(start)
    |> generation(target, growset)
  end

  def generation(%Plant{} = plant, 0, _) do
    IO.puts("")
    IO.puts("#{Plant.to_string(plant)}")

    plant
  end

  def generation(%Plant{} = plant, generations, growset) do
    -2..(byte_size(plant.state) + 1)
    |> Enum.reduce([], fn index, acc ->
      [
        if Plant.seed_state_at(plant, index + plant.left_index) in growset do
          "#"
        else
          "."
        end
        | acc
      ]
    end)
    |> Enum.reverse()
    |> List.to_string()
    |> Plant.new(plant.left_index - 2, plant.generation + 1)
    |> generation(generations - 1, growset)
  end
end
