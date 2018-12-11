#! /usr/bin/env elixir

defmodule Day3 do
  defp trim_map(input) do
    input
    |> Stream.map(fn string -> string |> String.trim() end)
  end

  defp parse_rect(rect_string) do
    [id, left, top, width, height] =
      rect_string
      #    |> IO.inspect()
      |> String.split(["#", " @ ", "x", ": ", ","], trim: true)
      |> Enum.map(&String.to_integer/1)

    {id, left..(left + width - 1), top..(top + height - 1)}
    #    |> IO.inspect()
  end

  def overlapping_inches(input) do
    input
    |> trim_map()
    |> Enum.map(&parse_rect/1)
    |> Enum.reduce(%{}, fn {id, x_range, y_range}, acc ->
      Enum.reduce(y_range, acc, fn y, acc ->
        Enum.reduce(x_range, acc, fn x, acc ->
          Map.update(acc, {x, y}, [id], fn p -> [id | p] end)
        end)
      end)
    end)
    #     |> IO.inspect()
    |> Enum.count(fn
      {_, list} when length(list) > 1 -> true
      _ -> false
    end)
  end

  def non_overlapping_id(_input) do
    9
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day3Test do
      use ExUnit.Case

      import Day3

      def string_to_stream(input) do
        {:ok, io} = StringIO.open(input)
        IO.stream(io, :line)
      end

      def test_stream do
        string_to_stream("""
        #1 @ 1,3: 4x4
        #2 @ 3,1: 4x4
        #3 @ 5,5: 2x2
        """)
      end

      test "Part 1" do
        assert overlapping_inches(test_stream()) == 4
      end

      test "Part 2" do
        assert non_overlapping_id(test_stream()) == 3
      end
    end

  [input_file] ->
    input_file
    |> File.stream!([], :line)
    |> Day3.overlapping_inches()
    |> IO.inspect(label: "Result Part 1")

    input_file
    |> File.stream!([], :line)
    |> Day3.non_overlapping_id()
    |> IO.inspect(label: "Result Part 2")

  _ ->
    IO.puts(:stderr, "Usage: #{Path.basename(__ENV__.file)} [--test | filename]")
    System.halt(1)
end
