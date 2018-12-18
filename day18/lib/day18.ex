defmodule Lumber do
  defstruct field: [],
            generation: 0,
            dimension: 0

  def new(string) when is_binary(string) do
    field =
      string
      |> String.split("\n", trim: true)
      |> Enum.map(&pad_line/1)
      |> Enum.map(&String.to_charlist/1)
      |> pad_field()

    #   IO.inspect(Enum.map(field, &length/1), charlists: :as_lists)

    length = length(hd(field))

    %__MODULE__{
      field: field,
      generation: 0,
      dimension: length - 2
    }
  end

  defp padding(n), do: padding(n, [])
  defp padding(0, acc), do: acc
  defp padding(n, acc), do: padding(n - 1, [?. | acc])

  defp pad_line(line), do: <<".", line::binary, ".">>

  defp pad_field(field) do
    length = length(hd(field))
    empty = padding(length)
    pad_list(field, empty)
  end

  defp pad_list(list, value) do
    [
      value
      | [value | Enum.reverse(list)]
        |> Enum.reverse()
    ]
  end

  def step(%__MODULE__{field: field, generation: generation, dimension: dimension}) do
    field = step(field)

    %__MODULE__{
      field: field,
      generation: generation + 1,
      dimension: dimension
    }
  end

  def step(field) when is_list(field) do
    ad =
      field
      |> adjacency_field()

    #      |> IO.inspect(label: "ad field")

    #    IO.inspect(Enum.map(field, &length/1), charlists: :as_lists)
    #    IO.inspect(Enum.map(ad, &length/1), charlists: :as_lists)

    step(field, ad, [])
  end

  defp step([_, _], [_, _], acc), do: Enum.reverse(acc)

  defp step(
         [_ | [field_line | _] = field_tail],
         [ad1 | [_, ad3 | _] = ad_tail],
         acc
       ) do
    step(field_tail, ad_tail, [next_field_line(ad1, field_line, ad3) | acc])
  end

  defp next_field_line(ad1, field_line, ad3) do
    next_field_line(ad1, field_line, ad3, [])
  end

  defp next_field_line([_, _], [_, _], [_, _], acc), do: Enum.reverse(acc)

  defp next_field_line(
         [_ | [ad1 | _] = ad1_tail],
         [left | [value, right | _] = field_line_tail],
         [_ | [ad3 | _] = ad3_tail],
         acc
       ) do
    next_value =
      case value do
        ?. ->
          ?.

        value ->
          counts =
            [
              [left, right]
              |> Enum.reduce(value_base(), &value_counter/2),
              ad1,
              ad3
            ]
            |> Enum.reduce(fn %{tree: t, yard: y}, %{tree: ta, yard: ya} ->
              %{tree: t + ta, yard: y + ya}
            end)

          case value do
            ?| -> if counts[:yard] >= 3, do: ?#, else: ?|
            ?# -> if counts[:yard] >= 1 and counts[:tree] >= 1, do: ?#, else: ?.
          end
      end

    next_field_line(ad1_tail, field_line_tail, ad3_tail, [next_value | acc])
  end

  @doc """
    
          iex> Lumber.adjacency_field([[?., ?., ?#, ?|, ?|, ?.]])
          [
            [
              %{tree: 0, yard: 0},
              %{tree: 0, yard: 1},
              %{tree: 1, yard: 1},
              %{tree: 2, yard: 1},
              %{tree: 2, yard: 0},
              %{tree: 0, yard: 0}
            ]
          ]
  """

  def adjacency_field(field) do
    field
    |> Enum.map(fn list -> adjacency_field(list, []) end)
  end

  def adjacency_field([_, _], acc) do
    Enum.reverse(acc)
    |> pad_list(%{yard: 0, tree: 0})
  end

  def adjacency_field([a | [b, c | _] = tail], acc) do
    #    IO.write(<<b>>)

    count =
      [a, b, c]
      |> Enum.reduce(value_base(), &value_counter/2)

    adjacency_field(tail, [count | acc])
  end

  defp value_base() do
    %{yard: 0, tree: 0}
  end

  defp value_counter(?#, acc), do: %{acc | yard: acc[:yard] + 1}
  defp value_counter(?|, acc), do: %{acc | tree: acc[:tree] + 1}
  defp value_counter(_, acc), do: acc
end

defmodule Day18 do
  @moduledoc """
  Documentation for Day18.
  """

  @doc """
        iex> l = Day18.lumber(".#.#...|#.
        ...>.....#|##|
        ...>.|..|...#.
        ...>..|#.....#
        ...>#.#|||#|#|
        ...>...#.||...
        ...>.|....|...
        ...>||...#|.#|
        ...>|.||||..|.
        ...>...#.|..|.")
        iex> Lumber.step(l).field
        ['.......##.',
         '......|###',
         '.|..|...#.',
         '..|#.....#',
         '..##||.|#|',
         '...#.||...',
         '.|....|...',
         '||....|..|',
         '|.||||..|.',
         '.....|..|.']
        
  """
  def lumber(input) do
    Lumber.new(input)
  end
end
