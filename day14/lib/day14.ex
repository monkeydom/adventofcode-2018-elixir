defmodule CircleList do
  require Record
  Record.defrecord(:circlelist, behind: [], ahead: [])

  @type circlelist :: record(:circlelist, behind: list, ahead: list)

  @doc """
      iex> CircleList.new([9])
      {:circlelist, [], [9]}

  """
  def new(list) when is_list(list) do
    circlelist(ahead: list)
  end

  @doc """
      iex> cl = CircleList.new([9,2])
      iex> CircleList.count(cl)
      2
  """

  def count(circlelist(behind: b, ahead: a)) do
    length(b) + length(a)
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
      {{:circlelist, [4], [2]}, 4}
      iex> {cl, 4} = CircleList.current(cl)
      {{:circlelist, [4], [2]}, 4}
      iex> {cl, 2} = CircleList.next(cl)
      {{:circlelist, [2, 4], []}, 2}
      iex> {cl, 2} = CircleList.current(cl)
      {{:circlelist, [2, 4], []}, 2}
      iex> {cl, 4} = CircleList.next(cl)
      {{:circlelist, [4], [2]}, 4}
      iex> {cl, 4} = CircleList.current(cl)
      {{:circlelist, [4], [2]}, 4}

  """
  def next(circlelist(behind: [], ahead: []) = cl), do: {cl, nil}
  def next(circlelist(behind: _, ahead: []) = cl), do: next(p_rotate(cl))

  def next(circlelist(behind: b, ahead: [e | t])) do
    current(circlelist(behind: [e | b], ahead: t))
  end

  def prev(circlelist(behind: [], ahead: []) = cl), do: {cl, nil}
  def prev(circlelist(behind: [], ahead: _) = cl), do: prev(p_rotate_back(cl))

  def prev(circlelist(behind: [e | t], ahead: a)) do
    current(circlelist(behind: [t], ahead: [e | a]))
  end

  defp p_rotate(circlelist(behind: b, ahead: [])) do
    circlelist(behind: [], ahead: Enum.reverse(b))
  end

  defp p_rotate_back(circlelist(behind: [], ahead: a)) do
    circlelist(behind: Enum.reverse(a), ahead: [])
  end

  @doc """
      iex> cl = CircleList.new([4,2])
      iex> {cl, 4} = CircleList.next(cl)
      iex> cl = CircleList.push(cl, 1)
      iex> {cl, 1} = CircleList.current(cl)
      {{:circlelist, [1, 4], [2]}, 1}
  """
  def push(circlelist(behind: b, ahead: a), el) do
    circlelist(behind: [el | b], ahead: a)
  end

  @doc """
      iex> cl = CircleList.new([4,2])
      iex> {cl, 4} = CircleList.next(cl)
      {{:circlelist, [4], [2]}, 4}
      iex> {cl, 4} = CircleList.pop(cl)
      {{:circlelist, [], [2]}, 4}
      iex> {cl, 2} = CircleList.pop(cl)
      {{:circlelist, [], []}, 2}
      iex> {cl, nil} = CircleList.pop(cl)
      {{:circlelist, [], []}, nil}
  """

  def pop(circlelist(behind: [], ahead: []) = cl), do: {cl, nil}

  def pop(cl) when Record.is_record(cl, :circlelist) do
    {circlelist(behind: [el | b], ahead: a), el} = current(cl)
    {circlelist(behind: b, ahead: a), el}
  end
end

defmodule Day14 do
  @moduledoc """
  Documentation for Day14.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day14.generate_sequence(9 + 10)
      19

  """
  def generate_sequence(length) do
    length
  end
end
