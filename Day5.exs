#! /usr/bin/env elixir

defmodule Day5 do
  def react_polymer(input) when is_binary(input), do: react_polymer(input, [])

  defp react_polymer(<<b, rest::binary>>, [a | acc]) when abs(a - b) == 32,
    do: react_polymer(rest, acc)

  defp react_polymer(<<b, rest::binary>>, acc), do: react_polymer(rest, [b | acc])

  defp react_polymer(<<>>, acc), do: acc |> Enum.reverse() |> List.to_string()
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day5Test do
      use ExUnit.Case

      import Day5

      test "Part 1" do
        assert react_polymer("dabAcCaCBAcCcaDA") == "dabCBAcaDA"
      end

      #      test "Part 2" do
      #        assert strategy2_guard_times_minute(test_stream()) == 99 * 45
      #      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Day5.react_polymer()
    |> byte_size()
    |> IO.inspect(label: "Result Part 1")

  _ ->
    IO.puts(:stderr, "Usage: #{Path.basename(__ENV__.file)} [--test | filename]")
    System.halt(1)
end
