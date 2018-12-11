#! /usr/bin/env elixir

defmodule Day5 do
  def react_polymer(input) when is_binary(input), do: react_polymer(input, [])

  defp react_polymer(<<b, rest::binary>>, [a | acc]) when abs(a - b) == 32,
    do: react_polymer(rest, acc)

  defp react_polymer(<<b, rest::binary>>, acc), do: react_polymer(rest, [b | acc])

  defp react_polymer(<<>>, acc), do: acc |> Enum.reverse() |> List.to_string()

  def find_best_removal(input) do
    candidate_list(input)
    |> Enum.reduce([], fn c, acc ->
      [{<<c>>, input |> remove(c) |> react_polymer |> byte_size()} | acc]
    end)
    |> Enum.sort()
    |> IO.inspect(label: "Reduction results")
    |> Enum.min_by(fn {_, v} -> v end)
  end

  defp unified(c) do
    if c > ?Z do
      c - 32
    else
      c
    end
  end

  def candidate_list(input), do: candidate_list(input, [])

  defp candidate_list(<<c, rest::binary>>, list) do
    u = unified(c)

    if u in list do
      candidate_list(rest, list)
    else
      candidate_list(rest, [u | list])
    end
  end

  defp candidate_list(<<>>, list), do: list

  defp remove(input, c), do: remove(input, [], c)

  defp remove(<<b, rest::binary>>, acc, c) when abs(b - c) == 0 or abs(b - c) == 32,
    do: remove(rest, acc, c)

  defp remove(<<b, rest::binary>>, acc, c), do: remove(rest, [b | acc], c)

  defp remove(<<>>, acc, _), do: acc |> Enum.reverse() |> List.to_string()
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

      test "Part 2" do
        assert find_best_removal("dabAcCaCBAcCcaDA") == {"C", 4}
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Day5.react_polymer()
    |> byte_size()
    |> IO.inspect(label: "Result Part 1")

    input_file
    |> File.read!()
    |> Day5.find_best_removal()
    |> IO.inspect(label: "Result Part 1")

  _ ->
    IO.puts(:stderr, "Usage: #{Path.basename(__ENV__.file)} [--test | filename]")
    System.halt(1)
end
