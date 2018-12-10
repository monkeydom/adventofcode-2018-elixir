#! /usr/bin/env elixir

defmodule Day1 do
  def final_frequency(input) when is_binary(input) do
    {:ok, io} = StringIO.open(input)
    final_frequency(IO.stream(io, :line))
  end

  def final_frequency(input) do
    input
    |> Stream.map(fn string -> string |> String.trim() |> String.to_integer() end)
    |> Enum.sum()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day1Test do
      use ExUnit.Case

      import Day1

      test "final_frequency" do
        assert final_frequency("""
               +1
               +1
               +1
               """) == 3
      end
    end

  [input_file] ->
    input_file
    |> File.stream!([], :line)
    |> Day1.final_frequency()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "Usage: Day1.exs [--file | filename]")
    System.halt(1)
end
