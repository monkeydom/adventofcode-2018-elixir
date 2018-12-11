#! /usr/bin/env elixir

defmodule Day2 do
  def string_to_stream(input) do
    {:ok, io} = StringIO.open(input)
    IO.stream(io, :line)
  end

  defp checksum_tuple(inputword) do
    inputword
    |> String.to_charlist()
    |> Enum.reduce(Map.new(), fn c, acc ->
      Map.update(acc, c, 1, &(&1 + 1))
    end)
    |> Enum.reduce({0, 0}, fn
      {_, 2}, {_, three} -> {1, three}
      {_, 3}, {two, _} -> {two, 1}
      _, acc -> acc
    end)
  end

  def checksum(input) do
    input
    |> Stream.map(fn string -> string |> String.trim() |> checksum_tuple() end)
    |> Enum.reduce(fn {two, three}, {zwei, drei} -> {two + zwei, three + drei} end)
    |> (fn {two, three} -> two * three end).()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day2Test do
      use ExUnit.Case

      import Day2

      test "checksum" do
        assert checksum(
                 Day2.string_to_stream("""
                 abcdef
                 bababc
                 abbcde
                 abcccd
                 aabcdd
                 abcdee
                 ababab                  
                 """)
               ) == 4 * 3
      end
    end

  [input_file] ->
    input_file
    |> File.stream!([], :line)
    |> Day2.checksum()
    |> IO.inspect(label: "Result Part 1")

  _ ->
    IO.puts(:stderr, "Usage: #{Path.basename(__ENV__.file)} [--test | filename]")
    System.halt(1)
end
