defmodule Day11 do
  @moduledoc """
  Documentation for Day11.
  """

  @doc """

      iex> Day11.grid_for_serial(18, 2)
      %{{1, 1} => -2, {1, 2} => -1, {2, 1} => -2, {2, 2} => 0}

  """
  def grid_for_serial(serial, size \\ 300) do
    #    grid = 
    for x <- 1..size, y <- 1..size, into: %{} do
      {{x, y}, power({x, y}, serial)}
    end

    #    IO.puts(grid_to_string(grid, size))
    #    grid
  end

  @doc """

      iex> Day11.largest_power_for_serial(18)
      {{33, 45}, 29}
      
      iex> Day11.largest_power_for_serial(5153)
      {{235, 18}, 31}
      

  """

  def largest_power_for_serial(serial, size \\ 300) do
    grid = grid_for_serial(serial, size)

    1..(size - 3)
    |> Enum.reduce({nil, 0}, fn y, acc ->
      1..(size - 3)
      |> Enum.reduce(acc, fn x, acc ->
        power =
          for x <- x..(x + 2), y <- y..(y + 2), into: [] do
            grid[{x, y}]
          end
          |> Enum.sum()

        case acc do
          {_, p} when power > p -> {{x, y}, power}
          acc -> acc
        end
      end)
    end)
  end

  @doc """

      iex> Day11.largest_power_triple(18)
      {{90,269,16}, 113}
      
      iex> Day11.largest_power_triple(42)
      {{232,251,12}, 119}
      

  """

  def largest_power_triple(serial, size \\ 300) do
    grid = grid_for_serial(serial, size)

    1..size
    |> Enum.reduce({nil, 0}, fn y, acc ->
      1..size
      |> Enum.reduce(acc, fn x, acc ->
        dimension = min(size - x, size - y)
        
        0..dimension
        |> Enum.reduce({acc, 0}, fn d, {{_coord, maxpower} = prev, power} -> 
            power = 
            case d do
              0 -> grid[{x,y}]
              d -> power + grid[{x+d, y+d}] +
                  (for c <- 0..(d-1) do grid[{x+d, y+c}] + grid[{x+c, y+d}] end |> Enum.sum())
            end
            if power > maxpower do
              {{{x,y,d+1}, power}, power}  
            else
              {prev, power}
            end
          end)
        |> case do
            {acc, _} -> acc
          end
        
      end)
    end)
  end


  @doc """

      iex> Day11.power({122,79}, 57)
      -5

      iex> Day11.power({217,196}, 39)
      0

      iex> Day11.power({101,153}, 71)
      4

  """

  def power({x, y}, serial) do
    rack_id = x + 10

    (((rack_id * y + serial) * rack_id)
     |> div(100)
     |> rem(10)) - 5
  end

  def grid_to_string(grid, size \\ 300) do
    1..size
    |> Enum.map(fn y ->
      for x <- 1..size, into: <<>> do
        String.pad_leading("#{grid[{x, y}]}", 3)
      end
    end)
    |> Enum.join("\n")
  end
end
