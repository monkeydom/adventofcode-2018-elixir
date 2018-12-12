#! /usr/bin/env elixir

defmodule Day7 do
  def order(input) do
    input
    |> deps_map()
    |> order([])
  end

  defp order(map, result) when map == %{},
    do: result |> Enum.reverse() |> List.to_string()

  defp order(deps, acc) do
    [next | _] =
      deps
      |> available_work_in_deps_map

    order(
      finish_work_in_deps_map(deps, next),
      [next | acc]
    )
  end

  defp available_work_in_deps_map(deps) do
    deps
    |> Enum.reduce(MapSet.new(), fn
      {k, []}, acc ->
        MapSet.put(acc, k)

      {_, cl}, acc ->
        Enum.reduce(cl, acc, fn x, acc ->
          case deps[x] do
            v when v in [[], nil] -> MapSet.put(acc, x)
            _ -> acc
          end
        end)
    end)
#    |> IO.inspect(label: "Candidates")
    |> Enum.sort()
  end

  defp finish_work_in_deps_map(deps, next) do
    Map.delete(deps, next)
    |> Enum.map(fn {k, l} -> {k, l -- [next]} end)
    |> Map.new()
  end

  def deps_map(input) do
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
    |> IO.inspect()
  end

  def order_for_workers(input, worker_count, base_dur) do
    deps =
      input
      |> deps_map()

    work_it_out(0, available_work_in_deps_map(deps), {worker_count, []}, deps, base_dur, [])
  end
  
  def duration(<<task>>, base_dur), do: base_dur + task - ?A + 1
  
  defp work_it_out(time, [], {_, []}, deps, _base_dur, result) when deps == %{}, 
    do: {time, result |> Enum.reverse() |> List.to_string()}
    
  defp work_it_out(time, work, workers, deps, base_dur, acc) do
     
    IO.inspect(List.to_string(work), label: " -- Work")
        
    # assign work
    {workers = {available_worker, worker_list}, remaining_work} =
    work
    |> Enum.reduce({workers, []}, fn 
      task, {{0, worker_list} = workers, remaining} -> 
        {workers, [task | remaining]}
        
      task, {{available, worker_list}, remaining} ->
        {{available - 1, [ {time + duration(task, base_dur), task} | worker_list ]}, remaining}
      end)
    
    IO.inspect({workers, List.to_string(acc)}, label: "Step at #{time}")

    # advance time
    {next_time, _task} = 
    worker_list
    |> Enum.min_by( &:erlang.element(1, &1) )
    
    # do work
    {new_deps, {_, work_list} = new_workers, new_acc} =
    worker_list
    |> Enum.filter(fn {t, task} -> t <= next_time end)
    |> finish_work(deps, workers, acc)
    
    new_work =
      work_list
      |> Enum.reduce(available_work_in_deps_map(new_deps), 
          fn {_t, w}, acc -> List.delete(acc, w) end)
    
    work_it_out(next_time, new_work, new_workers, new_deps, base_dur, new_acc)
  end
  
  defp finish_work([{_t, task} = worker | tail], deps, {available_worker, worker_list}, acc) do
    finish_work(tail, 
      finish_work_in_deps_map(deps, task),
      {available_worker + 1, worker_list -- [worker]},
      [task | acc])
  end

  defp finish_work([], deps, workers, acc) do
    {deps, workers, acc}
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

      test "Part 2" do
        assert order_for_workers(test_input, 2, 0) == "CABFDE"
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Day7.order()
    |> IO.inspect(label: "Result Part 1")

    input_file
    |> File.read!()
    |> Day7.order_for_workers(5, 60)
    |> IO.inspect(label: "Result Part 2")

  _ ->
    IO.puts(:stderr, "Usage: #{Path.basename(__ENV__.file)} [--test | filename]")
    System.halt(1)
end
