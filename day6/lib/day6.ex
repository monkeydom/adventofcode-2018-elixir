defmodule Day6 do
  @moduledoc """
  Documentation for Day6.
  """

  @doc """
      iex> Day6.area_with_max_total_distance("1, 1
      ...>1, 6
      ...>8, 3
      ...>3, 4
      ...>5, 5
      ...>8, 9
      ...>", 32)
      16
  """

  def area_with_max_total_distance(s, max_total_distance) do
    coordinates =
      s
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_coordinate/1)

    {x_range, y_range} = bounding_box(coordinates)

    grid =
      for x <- x_range, y <- y_range, into: %{} do
        position = {x, y}

        {position,
         coordinates
         |> Enum.map(fn coord -> manhattan_distance(position, coord) end)
         |> Enum.sum()}
      end

    grid
    |> Enum.count(fn {_, d} -> d < max_total_distance end)
  end

  @doc """
  ## Examples

      iex> Day6.largest_area("1, 1
      ...>1, 6
      ...>8, 3
      ...>3, 4
      ...>5, 5
      ...>8, 9
      ...>")
      17

  """
  def largest_area(s) do
    coordinates =
      s
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_coordinate/1)

    {x_range, y_range} = bounding_box(coordinates)

    grid =
      for x <- x_range, y <- y_range, into: %{} do
        position = {x, y}
        {position, distance_value(position, coordinates)}
      end

    infinites =
      (for(
         x <- [x_range.first, x_range.last],
         y <- (y_range.first + 1)..(y_range.last - 1),
         do: {x, y}
       ) ++ for(y <- [y_range.first, y_range.last], x <- x_range, do: {x, y}))
      |> Enum.map(fn coord -> grid[coord] end)
      |> Enum.reduce(MapSet.new(), fn
        {coord, _d}, acc ->
          MapSet.put(acc, coord)

        _, acc ->
          acc
      end)
      |> MapSet.to_list()

    grid
    |> Enum.reduce(%{}, fn
      {_, {coord, _d}}, acc ->
        Map.update(acc, coord, 1, fn v -> v + 1 end)

      _, acc ->
        acc
    end)
    |> Enum.filter(fn {coord, _count} -> coord not in infinites end)
    |> Enum.sort_by(fn {_, count} -> count end, &>=/2)
    |> List.first()
    |> elem(1)
  end

  def distance_value(position, coordinates) do
    coordinates
    |> Enum.map(fn coord -> {manhattan_distance(position, coord), coord} end)
    |> Enum.sort()
    |> case do
      [{a, _}, {a, _} | _] -> :equal
      [{d, coord} | _] -> {coord, d}
    end
  end

  def manhattan_distance({ax, ay}, {bx, by}), do: abs(ax - bx) + abs(ay - by)

  def parse_coordinate(s) do
    s
    |> String.split(", ")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  @doc """
    iex> Day6.bounding_box([{6,9}, {3,4}])
    {3..6, 4..9}
  """

  def bounding_box(coordinates) do
    {{min_x, _}, {max_x, _}} = coordinates |> Enum.min_max_by(fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = coordinates |> Enum.min_max_by(fn {_, y} -> y end)
    {min_x..max_x, min_y..max_y}
  end
end
