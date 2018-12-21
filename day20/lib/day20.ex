defmodule Day20 do
  @moduledoc """
  Documentation for Day20.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day20.part1("^WNE$")
      3

      iex> Day20.part1("^ENWWW(NEEE|SSE(EE|N))$")
      10

      iex> Day20.part1("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$")
      18

  """
  def part1(<<?^, path::binary>>) do
    pos = {0,0}
    distance = 0
    collect_paths(path, {pos, distance}, %{pos => distance}, [])
    |> Enum.max_by(fn {_pos, distance} -> distance end)
    |> elem(1)
  end
  
  defp collect_paths("$", _current, distance_map, []), do: distance_map

  defp collect_paths(<<h, tail::binary>>, {pos, distance}, distance_map, stack) when h in [?N, ?E, ?S, ?W] do
    next_pos = next_pos(pos, h)
    next_distance = min(Map.get(distance_map, next_pos, 99999999), distance + 1)
    distance_map = Map.put(distance_map, next_pos, next_distance)
    collect_paths(tail, {next_pos, next_distance}, distance_map, stack)
  end

  defp collect_paths(<<"(", tail::binary>>, {pos, distance}, distance_map, stack) do
    collect_paths(tail, {pos, distance}, distance_map, [{{pos, distance}, []} | stack])
  end

  defp collect_paths(<<"|", tail::binary>>, {pos, distance}, distance_map, [{{prev_pos, prev_distance}, branches} | stacktail]) do
    collect_paths(tail, {prev_pos, prev_distance}, distance_map, 
      [{{prev_pos, prev_distance}, [{pos, distance} | branches]} | stacktail])
  end

  defp collect_paths(<<")", tail::binary>>, current, distance_map, [{{_prev_pos, _prev_distance}, branches} | stacktail]) do
    [current | branches]
    |> Enum.reduce(distance_map, fn {pos, distance}, distance_map ->
      collect_paths(tail, {pos, distance}, distance_map, stacktail)
    end)
  end

  
  defp next_pos({x,y}, ?N), do: {x, y-1}
  defp next_pos({x,y}, ?S), do: {x, y+1}
  defp next_pos({x,y}, ?W), do: {x-1,y}
  defp next_pos({x,y}, ?E), do: {x+1,y}
end
