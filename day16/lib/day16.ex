defmodule Device do
  def instructions do
    [
      :addr,
      :addi,
      :mulr,
      :muli,
      :banr,
      :bani,
      :borr,
      :bori,
      :setr,
      :seti,
      :gtir,
      :gtri,
      :gtrr,
      :eqir,
      :eqri,
      :eqrr

      #      :noop
    ]
  end

  @spec store(list, integer, integer) :: list
  defdelegate store(regs, dest, value), to: List, as: :replace_at

  @spec read(list, non_neg_integer) :: integer
  def read(regs, index), do: Enum.at(regs, index)

  # Addition:
  # 
  # addr (add register) stores into register C the result of adding register A and register B.
  # addi (add immediate) stores into register C the result of adding register A and value B.

  @doc """

      iex> Device.step([1,2,0,4], {:addr, 0, 1, 2})
      [1, 2, 3, 4]

  """
  def step(regs, {:addr, a, b, c}), do: store(regs, c, read(regs, a) + read(regs, b))

  def step(regs, {:addi, a, b, c}), do: store(regs, c, read(regs, a) + b)

  # Multiplication:
  # 
  # mulr (multiply register) stores into register C the result of multiplying register A and register B.
  # muli (multiply immediate) stores into register C the result of multiplying register A and value B.

  def step(regs, {:mulr, a, b, c}), do: store(regs, c, read(regs, a) * read(regs, b))

  def step(regs, {:muli, a, b, c}), do: store(regs, c, read(regs, a) * b)

  # Bitwise AND:
  # 
  # banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
  # bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.

  use Bitwise

  def step(regs, {:banr, a, b, c}), do: store(regs, c, read(regs, a) &&& read(regs, b))

  def step(regs, {:bani, a, b, c}), do: store(regs, c, read(regs, a) &&& b)

  # Bitwise OR:
  # 
  # borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
  # bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.

  def step(regs, {:borr, a, b, c}), do: store(regs, c, read(regs, a) ||| read(regs, b))

  def step(regs, {:bori, a, b, c}), do: store(regs, c, read(regs, a) ||| b)

  # Assignment:
  # 
  # setr (set register) copies the contents of register A into register C. (Input B is ignored.)
  # seti (set immediate) stores value A into register C. (Input B is ignored.)

  def step(regs, {:setr, a, _, c}), do: store(regs, c, read(regs, a))

  def step(regs, {:seti, a, _, c}), do: store(regs, c, a)

  # Greater-than testing:
  # 
  # gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
  # gtri (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
  # gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.

  def step(regs, {:gtir, a, b, c}),
    do:
      store(
        regs,
        c,
        if a > read(regs, b) do
          1
        else
          0
        end
      )

  def step(regs, {:gtri, a, b, c}),
    do:
      store(
        regs,
        c,
        if read(regs, a) > b do
          1
        else
          0
        end
      )

  def step(regs, {:gtrr, a, b, c}),
    do:
      store(
        regs,
        c,
        if read(regs, a) > read(regs, b) do
          1
        else
          0
        end
      )

  # Equality testing:
  # 
  # eqir (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
  # eqri (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
  # eqrr (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.

  def step(regs, {:eqir, a, b, c}),
    do:
      store(
        regs,
        c,
        if a == read(regs, b) do
          1
        else
          0
        end
      )

  def step(regs, {:eqri, a, b, c}),
    do:
      store(
        regs,
        c,
        if read(regs, a) == b do
          1
        else
          0
        end
      )

  def step(regs, {:eqrr, a, b, c}),
    do:
      store(
        regs,
        c,
        if read(regs, a) == read(regs, b) do
          1
        else
          0
        end
      )

  # catch all noop

  def step(regs, _), do: regs
end

defmodule Day16 do
  @moduledoc """
  Documentation for Day16.
  """

  @doc """

      iex> Day16.matching_opcodes({{9, 2,1,2}, [3,2,1,1], [3,2,2,1]}) |> Enum.sort()
      [:addi, :mulr, :seti]

  """
  def matching_opcodes({ins, regs, regs_after}) do
    Device.instructions()
    |> Enum.reduce([], fn opcode, acc ->
      case Device.step(regs, put_elem(ins, 0, opcode)) do
        ^regs_after -> [opcode | acc]
        _ -> acc
      end
    end)
  end

  @doc """

        iex> Day16.part1("Before: [3, 3, 2, 3]
        ...>3 1 2 2
        ...>After:  [3, 3, 2, 3]
        ...>
        ...>Before: [1, 3, 0, 1]
        ...>12 0 2 3
        ...>After:  [1, 3, 0, 0]
        ...>
        ...>Before: [0, 3, 2, 0]
        ...>14 2 3 0
        ...>After:  [1, 3, 2, 0]
        ...>
        ...>Before: [2, 3, 3, 3]
        ...>10 0 3 0
        ...>After:  [2, 3, 3, 3]
        ...>
        ...>Before: [0, 1, 2, 0]
        ...>7 1 2 3
        ...>After:  [0, 1, 2, 0]
        ...>
        ...>Before: [3, 1, 2, 0]
        ...>7 1 2 2
        ...>After:  [3, 1, 0, 0]
        ...>
        ...>Before: [1, 2, 1, 3]
        ...>6 2 2 2
        ...>After:  [1, 2, 2, 3]
        ...>
        ...>Before: [1, 3, 2, 3]
        ...>3 3 2 3
        ...>After:  [1, 3, 2, 2]
        ...>
        ...>Before: [0, 1, 2, 0]
        ...>8 0 0 1
        ...>After:  [0, 0, 2, 0]
        ...>
        ...>")
        6
  """

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> parse_triples
    |> Enum.map(&matching_opcodes/1)
    |> Enum.count(fn v -> length(v) >= 3 end)
  end

  defp parse_regs(s) do
    s
    |> String.split(", ")
    |> Enum.reduce([], fn s, acc -> [elem(Integer.parse(s), 0) | acc] end)
    |> Enum.reverse()
  end

  defp parse_instruction(s) do
    s
    |> String.split(" ")
    |> Enum.reduce([], fn s, acc -> [elem(Integer.parse(s), 0) | acc] end)
    |> Enum.reverse()
    |> List.to_tuple()
  end

  defp parse_triples(list) when is_list(list), do: parse_triples(list, [])

  defp parse_triples(
         [
           <<"Before: [", before_string::binary>>,
           instruction_string,
           <<"After:  [", after_string::binary>> | tail
         ],
         acc
       ) do
    parse_triples(tail, [
      {
        parse_instruction(instruction_string),
        parse_regs(before_string),
        parse_regs(after_string)
      }
      | acc
    ])
  end

  defp parse_triples(_, acc), do: Enum.reverse(acc)

  def deduce_opcodes(input) do
    input
    |> String.split("\n", trim: true)
    |> parse_triples()
    |> Enum.map(fn tr -> {matching_opcodes(tr), tr} end)
    |> Enum.sort_by(fn {l, _} -> length(l) end)
    |> deduce_opcodes(%{})
  end

  defp deduce_opcodes([], acc), do: acc

  defp deduce_opcodes([{[opcode], {{opnr, _, _, _}, _, _}} | tail], acc) do
    new_acc = Map.put_new(acc, opnr, opcode)

    tail =
      Enum.reduce(tail, [], fn
        {opcode_list, {{_opnr, _, _, _}, _, _} = operation}, acc ->
          case Enum.reject(opcode_list, &(&1 == opcode)) do
            [] -> acc
            new_ol -> [{new_ol, operation} | acc]
          end
      end)
      |> Enum.sort_by(fn {l, _} -> length(l) end)

    deduce_opcodes(tail, new_acc)
  end
  
  
  def run_program(input, decoder_map) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
    |> Enum.map(fn ins -> put_elem(ins, 0, decoder_map[elem(ins, 0)]) end)
    |> Enum.reduce([0,0,0,0], fn ins, regs -> Device.step(regs, ins) end)
  end
end
