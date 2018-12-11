#! /usr/bin/env elixir

defmodule Day3 do
  defp trim_map(input) do
    input
    |> Stream.map(fn string -> string |> String.trim() end)
  end

  def overlapping_inches(input) do
    input
    |> trim_map
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
    |> Day3.checksum()
    |> IO.inspect(label: "Result Part 1")

    input_file
    |> File.stream!([], :line)
    |> Day3.common_letters()
    |> IO.inspect(label: "Result Part 2")

  _ ->
    IO.puts(:stderr, "Usage: #{Path.basename(__ENV__.file)} [--test | filename]")
    System.halt(1)
end
