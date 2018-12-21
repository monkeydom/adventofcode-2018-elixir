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

      iex> Day20.part1("^ENWWW(NEEE|SSEEE|SSEN)$")
      10

      iex> Day20.part1("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$")
      18


      iex> Day20.part1("^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$")
      23
      
      iex> Day20.part1("^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$")
      31
  """
  def part1(<<?^, path::binary>>) do
    pos = {0,0}
    distance = 0
    collect_paths(path, {pos, distance}, %{pos => distance}, [])
    |> Enum.max_by(fn {_pos, distance} -> distance end)
    |> elem(1)
  end
  
  defp collect_paths("$", {pos, distance}, distance_map, []) do
    # IO.write(<<"\u001b[5D">>)
    # IO.write(String.pad_leading("#{distance}", 5, " "))
    distance_map
  end

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
    # branch_length = length(branches)+1
    #IO.write(String.pad_leading("", branch_length, "1234567890"))
    [current | branches]
    |> Enum.uniq()
    |> Enum.reduce(distance_map, fn {pos, distance}, distance_map ->
      collect_paths(tail, {pos, distance}, distance_map, stacktail)
    end)
  end

  
  defp next_pos({x,y}, ?N), do: {x, y-1}
  defp next_pos({x,y}, ?S), do: {x, y+1}
  defp next_pos({x,y}, ?W), do: {x-1,y}
  defp next_pos({x,y}, ?E), do: {x+1,y}
end
