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

  @doc """
    
    iex> l250 = 0..249 |> Enum.to_list() |> EList.new() 
    iex> l250 |> EList.at(2)
    2
    iex> l250 |> EList.at(200)
    200
    
    iex> l250 = 0..249 |> Enum.reduce(EList.new([]), fn el, acc -> EList.insert_at(acc, el, acc.length) end)  
    iex> l250 |> EList.at(2)
    2
    iex> l250 |> EList.at(200)
    200

  """

  def at(%EList{list: list}, location) when is_list(list),
    do: Enum.at(list, location)

  def at(%EList{list: {elists}}, location) do
    elists
    |> Enum.reduce({nil, location}, fn
      _el, {entry, nil} ->
        {entry, nil}

      el, {nil, loc} ->
        if loc < el.length do
          {EList.at(el, loc), nil}
        else
          {nil, loc - el.length}
        end
    end)
    |> case do
      {entry, _loc} -> entry
    end
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

  def to_list(%EList{list: list}) when is_list(list),
    do: list

  def to_list(%EList{list: {elists}}) do
    elists
    |> Enum.map(fn el -> to_list(el) end)
    |> Enum.concat()
  end
end

defmodule Day14 do
  defstruct recipies: EList.new([3, 7]),
            positions: [{0, 3}, {1, 7}],
            insert_buffer: [0, 0, 0, 0, 0]

  @moduledoc """
  Documentation for Day14.
  """

  @doc """

      iex> Day14.generate_sequence(9 + 10)
      [3, 7, 1, 0, 1, 0, 1, 2, 4, 5, 1, 5, 8, 9, 1, 6, 7, 7, 9]

      iex> Day14.solution(9)
      "5158916779"

  """
  def generate_sequence(length) do
    sequence_step(%__MODULE__{}, length - 2)
  end

  def sequence_step(%__MODULE__{recipies: recipies}, additional_length)
      when additional_length <= 0,
      do: EList.to_list(recipies)

  def sequence_step(%__MODULE__{recipies: recipies, positions: positions}, additional_length) do
    # IO.inspect({positions, recipies})

    next =
      positions
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()

    {recipies, additional_length} =
      if next >= 10 do
        [div(next, 10), rem(next, 10)]
      else
        [rem(next, 10)]
      end
      |> Enum.reduce({recipies, additional_length}, fn el, {recipies, add_length} ->
        {EList.insert_at(recipies, recipies.length, el), add_length - 1}
      end)

    positions =
      positions
      |> Enum.map(fn {pos, value} ->
        pos = rem(pos + value + 1, recipies.length)
        {pos, EList.at(recipies, pos)}
      end)

    sequence_step(%__MODULE__{recipies: recipies, positions: positions}, additional_length)
  end

  def solution(length) do
    generate_sequence(length + 10)
    |> Enum.slice(length, 10)
    |> Enum.map(fn el -> el + ?0 end)
    |> List.to_string()
  end

  @doc """

      iex> Day14.solution2([5,1,5,8,9])
      9

      iex> Day14.solution2([0,1,2,4,5])
      5

      iex> Day14.solution2([9,2,5,1,0])
      18

      iex> Day14.solution2([5,9,4,1,4])
      2018

  """

  def solution2(match_list) do
    sequence_test(%__MODULE__{}, match_list)
  end

  def sequence_test(
        %__MODULE__{recipies: recipies, positions: positions, insert_buffer: match_list},
        match_list
      ),
      do: recipies.length - length(match_list)

  def sequence_test(
        %__MODULE__{recipies: recipies, positions: positions, insert_buffer: buffer},
        match_list
      ) do
    next =
      positions
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()

    {recipies, buffer} =
      if next >= 10 do
        [div(next, 10), rem(next, 10)]
      else
        [rem(next, 10)]
      end
      |> Enum.reduce({recipies, buffer}, fn el, {recipies, [_ | buffer]} ->
        {EList.insert_at(recipies, recipies.length, el),
         Enum.reverse([el | Enum.reverse(buffer)])}
      end)

    positions =
      positions
      |> Enum.map(fn {pos, value} ->
        pos = rem(pos + value + 1, recipies.length)
        {pos, EList.at(recipies, pos)}
      end)

    sequence_test(
      %__MODULE__{recipies: recipies, positions: positions, insert_buffer: buffer},
      match_list
    )
  end
end
