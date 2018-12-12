defmodule Day8 do
  @moduledoc """
  Documentation for Day8.
  """

  @type metadata :: integer
  @type treenode :: {[treenode], [metadata]}

  @doc ~S"""

      iex> Day8.tree_from_string("0 1 99")
      {[],[99]}


      iex> Day8.tree_from_string("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")
      {
        [
        {[],[10,11,12]},
        {[{[],
           [99]}],
         [2]}
        ],
        [1,1,2]
      }

  """

  def tree_from_string(s) do
    s
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> parse_tree()
  end

  defp parse(tail, 0), do: {[], tail}

  defp parse(tail, node_count) do
    1..node_count
    |> Enum.reduce({[], tail}, fn _, {list, tail} ->
      {node, tail} = parse_node(tail)
      {[node | list], tail}
    end)
  end

  defp parse_node([child_count, metadatacount | tail]) do
    {child_nodes, tail} = parse(tail, child_count)

    {metadata, tail} = Enum.split(tail, metadatacount)

    {{Enum.reverse(child_nodes), metadata}, tail}
  end

  def parse_tree(list) do
    {root, []} =
      list
      |> parse_node()

    root
  end
end
