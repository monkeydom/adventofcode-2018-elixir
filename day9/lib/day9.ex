defmodule CircleList do
  require Record
  Record.defrecord(:circlelist, behind: [], ahead: [], length: 0)

  @type circlelist :: record(:circlelist, behind: list, ahead: list, length: non_neg_integer)

  @doc """
      iex> CircleList.new([9])
      {:circlelist, [], [9], 1}

  """
  def new(list) when is_list(list) do
    circlelist(ahead: list, length: length(list))
  end

  @doc """
      iex> cl = CircleList.new([9,2])
      iex> CircleList.count(cl)
      2
  """

  def count(circlelist(length: l)) do
    l
  end

  def current(circlelist(behind: [], ahead: []) = cl), do: {cl, nil}

  def current(circlelist(behind: b, ahead: _a) = cl) do
    case b do
      [n | _] -> {cl, n}
      [] -> current(p_rotate_back(cl))
    end
  end

  @doc """
      iex> cl = CircleList.new([4,2])
      iex> {cl, 4} = CircleList.next(cl)
      {{:circlelist, [4], [2], 2}, 4}
      iex> {cl, 4} = CircleList.current(cl)
      {{:circlelist, [4], [2], 2}, 4}
      iex> {cl, 2} = CircleList.next(cl)
      {{:circlelist, [2, 4], [], 2}, 2}
      iex> {cl, 2} = CircleList.current(cl)
      {{:circlelist, [2, 4], [], 2}, 2}
      iex> {cl, 4} = CircleList.next(cl)
      {{:circlelist, [4], [2], 2}, 4}
      iex> {cl, 4} = CircleList.current(cl)
      {{:circlelist, [4], [2], 2}, 4}

  """
  def next(circlelist(behind: [], ahead: []) = cl), do: {cl, nil}
  def next(circlelist(behind: _, ahead: []) = cl), do: next(p_rotate(cl))

  def next(circlelist(behind: b, ahead: [e | t], length: l)) do
    current(circlelist(behind: [e | b], ahead: t, length: l))
  end

  @doc """

      iex> {cl, 4} = CircleList.prev(CircleList.new([4,2]))
      {{:circlelist, [4], [2], 2}, 4}
      iex> {cl, 4} = CircleList.current(cl)
      {{:circlelist, [4], [2], 2}, 4}
  """

  def prev(circlelist(behind: [], ahead: []) = cl), do: {cl, nil}
  def prev(circlelist(behind: [], ahead: _) = cl), do: prev(p_rotate_back(cl))

  def prev(circlelist(behind: [e | t], ahead: a, length: l)) do
    current(circlelist(behind: t, ahead: [e | a], length: l))
  end

  defp p_rotate(circlelist(behind: b, ahead: [], length: l)) do
    circlelist(behind: [], ahead: Enum.reverse(b), length: l)
  end

  defp p_rotate_back(circlelist(behind: [], ahead: a, length: l)) do
    circlelist(behind: Enum.reverse(a), ahead: [], length: l)
  end

  @doc """
      iex> cl = CircleList.new([4,2])
      iex> {cl, 4} = CircleList.next(cl)
      iex> cl = CircleList.push(cl, 1)
      iex> {cl, 1} = CircleList.current(cl)
      {{:circlelist, [1, 4], [2], 3}, 1}
  """
  def push(circlelist(behind: b, ahead: a, length: l), el) do
    circlelist(behind: [el | b], ahead: a, length: l + 1)
  end

  @doc """
      iex> cl = CircleList.new([4,2])
      iex> {cl, 4} = CircleList.next(cl)
      {{:circlelist, [4], [2], 2}, 4}
      iex> {cl, 4} = CircleList.pop(cl)
      {{:circlelist, [], [2], 1}, 4}
      iex> {cl, 2} = CircleList.pop(cl)
      {{:circlelist, [], [], 0}, 2}
      iex> {cl, nil} = CircleList.pop(cl)
      {{:circlelist, [], [], 0}, nil}
  """

  def pop(circlelist(behind: [], ahead: []) = cl), do: {cl, nil}

  def pop(cl) when Record.is_record(cl, :circlelist) do
    {circlelist(behind: [el | b], ahead: a, length: l), el} = current(cl)
    {circlelist(behind: b, ahead: a, length: l - 1), el}
  end

  def to_list(circlelist(behind: b, ahead: a)), do: a ++ Enum.reverse(b)
end

defmodule EList do
  defstruct list: [],
            length: 0

  def new(list, length) do
    %EList{
      list: list,
      length: length
    }
  end

  def new(list) do
    %EList{
      list: list,
      length: length(list)
    }
  end

  def pop_at(%EList{list: list} = elist, location) when is_list(list) do
    {entry, list} = List.pop_at(elist.list, location)

    {
      entry,
      %EList{
        list: list,
        length: elist.length - 1
      }
    }
  end

  def pop_at(%EList{list: {elists}} = elist, location) do
    {new_elists, {entry}} =
      elists
      |> Enum.reduce({[], location}, fn
        el, {acc, {entry}} ->
          {[el | acc], {entry}}

        el, {acc, loc} ->
          if loc < el.length do
            {entry, new_el} = EList.pop_at(el, loc)
            {[new_el | acc], {entry}}
          else
            {[el | acc], loc - el.length}
          end
      end)

    {
      entry,
      %EList{
        list: {Enum.reverse(new_elists)},
        length: elist.length - 1
      }
    }
  end

  def insert_at(%EList{list: list} = elist, location, value) when is_list(list) do
    if elist.length == 100 do
      {l1, l2} = Enum.split(list, 50)

      EList.insert_at(
        %EList{
          list:
            {[
               new(l1, 50),
               new(l2, 50)
             ]},
          length: elist.length
        },
        location,
        value
      )
    else
      %EList{
        list: List.insert_at(elist.list, location, value),
        length: elist.length + 1
      }
    end
  end

  def insert_at(%EList{list: {elists}} = elist, location, value) do
    new_elists =
      elists
      |> Enum.reduce({[], location}, fn
        el, {acc, loc} ->
          if loc <= el.length do
            [EList.insert_at(el, loc, value) | acc]
          else
            {[el | acc], loc - el.length}
          end

        el, acc when is_list(acc) ->
          [el | acc]
      end)
      |> Enum.reverse()

    %EList{
      list: {new_elists},
      length: elist.length + 1
    }
  end
end

defmodule Day9 do
  defstruct scores: %{},
            marbles: CircleList.new([0]),
            player_count: 0,
            last_played_marble: 0

  def new(player_count) do
    %Day9{player_count: player_count}
  end

  def to_string() do
  end

  @moduledoc """
  Documentation for Day9.
  """

  @doc """
        iex> Day9.marble_game(9, 25)
        32

        iex> Day9.marble_game(10,1618)
        8317

        iex> Day9.marble_game(13,7999)
        146373

        iex> Day9.marble_game(17,1104)
        2764

        iex> Day9.marble_game(21,6111)
        54718

        iex> Day9.marble_game(30,5807)
        37305

        iex> Day9.marble_game(30,5807 * 5)
        822794

        iex> Day9.marble_game(465,71498)
        383475

        iex> Day9.marble_game(465,71498 * 100)
        3148209772

  """
  def marble_game(player_count, last_marble) do
    initial = new(player_count)
    #    IO.puts("#{initial}")

    1..last_marble
    |> Enum.reduce(
      initial,
      &marble_game_step/2
    )
    #    |> (fn state -> IO.puts("#{state}")
    #      state
    #    end).()
    #    |> IO.inspect(label: "End")
    |> case do
      %Day9{scores: scores} -> Enum.map(scores, fn {_player, score} -> score end)
    end
    |> Enum.max()
  end

  def marble_game_step(marble, state) do
    state = %Day9{state | last_played_marble: marble}

    case rem(marble, 23) do
      0 ->
        player = rem(marble - 1, state.player_count)

        {marbles, taken} =
          Enum.reduce(1..7, state.marbles, fn _, m -> elem(CircleList.prev(m), 0) end)
          |> CircleList.pop()

        #          |> IO.inspect 

        %Day9{
          state
          | scores:
              Map.update(state.scores, player, taken + marble, fn o -> o + taken + marble end),
            marbles: elem(CircleList.next(marbles), 0)
        }

      _ ->
        {marbles, _} = CircleList.next(state.marbles)
        marbles = CircleList.push(marbles, marble)

        %Day9{
          state
          | marbles: marbles
        }
    end

    #        |> (fn state -> IO.puts("#{state}")
    #          state
    #        end).()
  end
end

defimpl String.Chars, for: Day9 do
  def to_string(state) do
    marble = state.last_played_marble

    display_player = rem(marble - 1, state.player_count)

    IO.iodata_to_binary([
      "[#{
        if display_player >= 0 do
          display_player + 1
        else
          "-"
        end
      }] ",
      CircleList.to_list(state.marbles)
      |> Enum.map(fn marble ->
        String.pad_leading(Integer.to_string(marble), 3, "  ")
      end)
    ])
  end
end
