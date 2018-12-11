#! /usr/bin/env elixir

defmodule Day1 do
  def string_to_stream(input) do
    {:ok, io} = StringIO.open(input)
    IO.stream(io, :line)
  end

  def final_frequency(input) do
    input
    |> Stream.map(fn string -> string |> String.trim() |> String.to_integer() end)
    |> Enum.sum()
  end

  def first_repeated_frequency(input) when is_list(input) do
    input
    |> IO.inspect(label: "input")
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join("\n")
    |> string_to_stream
    |> first_repeated_frequency
  end

  def first_repeated_frequency(input) do
    input
    |> Stream.map(fn string -> string |> String.trim() |> String.to_integer() end)
    |> Enum.to_list()
    |> Stream.cycle()
    |> Enum.reduce_while({MapSet.new([0]), 0}, fn x, {set, current} ->
      next = current + x

      case MapSet.member?(set, next) do
        true -> {:halt, next}
        _ -> {:cont, {MapSet.put(set, next), next}}
      end
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day1Test do
      use ExUnit.Case

      import Day1

      test "final_frequency" do
        assert final_frequency(
                 Day1.string_to_stream("""
                 +1
                 +1
                 +1
                 """)
               ) == 3
      end

      test "first_repeated_frequency_1" do
        assert first_repeated_frequency([+1, -1]) == 0
      end

      test "first_repeated_frequency_2" do
        assert first_repeated_frequency([+3, +3, +4, -2, -4]) == 10
      end

      test "first_repeated_frequency_3" do
        assert first_repeated_frequency([-6, +3, +8, +5, -6]) == 5
      end

      test "first_repeated_frequency_4" do
        assert first_repeated_frequency([+7, +7, -2, -7, -4]) == 14
      end
    end

  [input_file] ->
    input_file
    |> File.stream!([], :line)
    |> Day1.final_frequency()
    |> IO.inspect(label: "Result Part 1")

    input_file
    |> File.stream!([], :line)
    |> Day1.first_repeated_frequency()
    |> IO.inspect(label: "Result Part 2")

  _ ->
    IO.puts(:stderr, "Usage: Day1.exs [--file | filename]")
    System.halt(1)
end
