defmodule Star do
  defstruct position: nil,
            velocity: nil

  def new([position, velocity]) do
    %__MODULE__{position: position, velocity: velocity}
  end

  def display_at(starlist, time) do
    starlist
    |> starfield_at(time)
    |> starfield_to_string()
    |> IO.puts()
  end

  def starfield_at(starlist, time) do
    starlist
    |> Enum.reduce(%{}, fn %__MODULE__{position: {x, y}, velocity: {dx, dy}}, acc ->
      Map.put(acc, {x + dx * time, y + dy * time}, "#")
    end)
  end

  @doc """

  iex(1)> Star.starfield_to_string(%{
  ...(1)>                    {-4, 0} => "#",
  ...(1)>                    {-3, 8} => "#",
  ...(1)>                    {-2, 3} => "#",
  ...(1)>                    {-2, 9} => "#"
  ...(1)>              })
  "#..\n...\n...\n..#\n...\n...\n...\n...\n.#.\n..#"

  """

  def starfield_bounding_box(starmap) do
    x_range =
      starmap
      |> Enum.min_max_by(fn {{x, _y}, _value} -> x end)
      |> case do
        {{{min, _}, _}, {{max, _}, _}} -> min..max
      end

    y_range =
      starmap
      |> Enum.min_max_by(fn {{_x, y}, _value} -> y end)
      |> case do
        {{{_, min}, _}, {{_, max}, _}} -> min..max
      end

    {x_range, y_range}
  end

  def starfield_expanse_at(starlist, time) do
    starlist
    |> starfield_at(time)
    |> starfield_bounding_box()
    |> case do
      {x_range, y_range} -> Enum.count(x_range) + Enum.count(y_range)
    end
  end

  def starfield_to_string(starmap) do
    {x_range, y_range} = starfield_bounding_box(starmap)

    case Enum.count(x_range) + Enum.count(y_range) do
      count when count > 1000 ->
        "Dimensions too big: #{inspect(x_range)} - #{inspect(y_range)}"

      _ ->
        y_range
        |> Enum.map(fn y ->
          for x <- x_range, into: <<>> do
            starmap[{x, y}] || "."
          end
        end)
        |> Enum.join("\n")
    end
  end
end

defmodule Day10 do
  @moduledoc """
  Documentation for Day10.
  """

  @doc """
  Hello world.

  ## Examples

      iex> stars = Day10.parse_input("position=< 9,  1> velocity=< 0,  2>
      ...> position=< 7,  0> velocity=<-1,  0>
      ...> position=< 3, -2> velocity=<-1,  1>
      ...> position=< 6, 10> velocity=<-2, -1>
      ...> position=< 2, -4> velocity=< 2,  2>
      ...> position=<-6, 10> velocity=< 2, -2>
      ...> position=< 1,  8> velocity=< 1, -1>
      ...> position=< 1,  7> velocity=< 1,  0>
      ...> position=<-3, 11> velocity=< 1, -2>
      ...> position=< 7,  6> velocity=<-1, -1>
      ...> position=<-2,  3> velocity=< 1,  0>
      ...> position=<-4,  3> velocity=< 2,  0>
      ...> position=<10, -3> velocity=<-1,  1>
      ...> position=< 5, 11> velocity=< 1, -2>
      ...> position=< 4,  7> velocity=< 0, -1>
      ...> position=< 8, -2> velocity=< 0,  1>
      ...> position=<15,  0> velocity=<-2,  0>
      ...> position=< 1,  6> velocity=< 1,  0>
      ...> position=< 8,  9> velocity=< 0, -1>
      ...> position=< 3,  3> velocity=<-1,  1>
      ...> position=< 0,  5> velocity=< 0, -1>
      ...> position=<-2,  2> velocity=< 2,  0>
      ...> position=< 5, -2> velocity=< 1,  2>
      ...> position=< 1,  4> velocity=< 2,  1>
      ...> position=<-2,  7> velocity=< 2, -2>
      ...> position=< 3,  6> velocity=<-1, -1>
      ...> position=< 5,  0> velocity=< 1,  0>
      ...> position=<-6,  0> velocity=< 2,  0>
      ...> position=< 5,  9> velocity=< 1, -2>
      ...> position=<14,  7> velocity=<-2,  0>
      ...> position=<-3,  6> velocity=< 2, -1>")
      iex> Star.starfield_at(stars, 1)
      %{{-4, 0} => "#", {-4, 8} => "#", {-2, 3} => "#", {-2, 9} => "#", {-1, 3} => "#", {-1, 5} => "#", {0, 2} => "#", {0, 4} => "#", {0, 5} => "#", {2, -1} => "#", {2, 4} => "#", {2, 5} => "#", {2, 6} => "#", {2, 7} => "#", {3, 5} => "#", {4, -2} => "#", {4, 6} => "#", {4, 9} => "#", {6, 0} => "#", {6, 5} => "#", {6, 7} => "#", {6, 9} => "#", {8, -1} => "#", {8, 8} => "#", {9, -2} => "#", {9, 3} => "#", {12, 7} => "#", {13, 0} => "#"}

  """
  def parse_input(string) do
    string
    |> String.split("\n", trim: true)
    |> Enum.map(fn l -> parse_line(l) end)
  end

  @doc """
    iex> Day10.parse_line("position=<-3, 11> velocity=< 1, -2>")
    %Star{position: {-3, 11}, velocity: {1, -2}}

    iex> Day10.parse_line("position=< 43957, -43595> velocity=<-4,  4>")
    %Star{position: {43957, -43595}, velocity: {-4, 4}}
    
  """

  def parse_line(string) do
    string
    |> String.split([" ", ">", "<", ", "], trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [_, x, y] -> {String.to_integer(x), String.to_integer(y)} end)
    |> Star.new()
  end
end
