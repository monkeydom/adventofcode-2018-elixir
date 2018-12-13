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
        list: { Enum.reverse(new_elists) },
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
            current: 0,
            marbles: EList.new([0]),
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
        current = rem(state.current + state.marbles.length - 7, state.marbles.length)
        {taken, marbles} = EList.pop_at(state.marbles, current)

        %Day9{
          state
          | scores:
              Map.update(state.scores, player, taken + marble, fn o -> o + taken + marble end),
            current: current,
            marbles: marbles
        }

      _ ->
        current = rem(state.current + 1, state.marbles.length) + 1

        %Day9{
          state
          | current: current,
            marbles: EList.insert_at(state.marbles, current, marble)
        }
    end

    #    |> (fn state -> IO.puts("#{state}")
    #      state
    #    end).()
  end
end

defimpl String.Chars, for: Day9 do
  def to_string(state) do
    marble = state.last_played_marble
    current = state.current

    display_player = rem(marble - 1, state.player_count)

    IO.iodata_to_binary([
      "[#{
        if display_player >= 0 do
          display_player + 1
        else
          "-"
        end
      }] ",
      state.marbles
      |> Enum.map(fn marble ->
        String.pad_leading(Integer.to_string(marble), 2, " ")
      end)
      |> Enum.with_index()
      |> Enum.map(fn
        {m, ^current} -> ["(", m, ")"]
        {m, _} -> [" ", m, " "]
      end)
    ])
  end
end
