#! /usr/bin/env elixir

defmodule Day7 do
  def order(input) do
    deps =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn <<"Step ", a, " must be finished before step ", b, " can begin.">> ->
        {<<b>>, <<a>>}
      end)
      |> Enum.reduce(
        %{},
        fn {b, a}, map ->
          Map.put_new(Map.update(map, b, [a], fn p -> [a | p] end), a, [])
        end
      )

    IO.inspect(deps)

    order(deps, [])
  end

  defp order(map, result) when map == %{}, do: result |> Enum.reverse() |> List.to_string()

  defp order(deps, acc) do
    
    [next | _] = 
    deps
    |> Enum.reduce(MapSet.new(), fn
      {k, []}, acc -> MapSet.put(acc, k)
      {_, cl}, acc -> Enum.reduce(cl, acc, fn x, acc -> case deps[x] do 
        v when v in [[], nil] -> MapSet.put(acc, x)
        _ -> acc        
      end end)
    end)
    |> IO.inspect(label: "Candidates")
    |> Enum.sort
    
    order(
      Map.delete(deps, next)
      |> Enum.map(fn {k, l} -> {k, l -- [next]} end)
      |> Map.new, 
      [next | acc])
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day7Test do
      use ExUnit.Case

      import Day7

      def test_input do
        """
        Step C must be finished before step A can begin.
        Step C must be finished before step F can begin.
        Step A must be finished before step B can begin.
        Step A must be finished before step D can begin.
        Step B must be finished before step E can begin.
        Step D must be finished before step E can begin.
        Step F must be finished before step E can begin.
        """
      end

      test "Part 1" do
        assert order(test_input()) == "CABDFE"
      end

      #      test "Part 2" do
      #        assert find_best_removal("dabAcCaCBAcCcaDA") == {"C", 4}
      #      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Day7.order()
    |> IO.inspect(label: "Result Part 1")

  _ ->
    IO.puts(:stderr, "Usage: #{Path.basename(__ENV__.file)} [--test | filename]")
    System.halt(1)
end
