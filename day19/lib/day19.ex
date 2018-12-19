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

  def step(regs, {:gtir, a, b, c}), do: store(regs, c, if(a > read(regs, b), do: 1, else: 0))

  def step(regs, {:gtri, a, b, c}), do: store(regs, c, if(read(regs, a) > b, do: 1, else: 0))

  def step(regs, {:gtrr, a, b, c}),
    do: store(regs, c, if(read(regs, a) > read(regs, b), do: 1, else: 0))

  # Equality testing:
  # 
  # eqir (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
  # eqri (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
  # eqrr (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.

  def step(regs, {:eqir, a, b, c}), do: store(regs, c, if(a == read(regs, b), do: 1, else: 0))

  def step(regs, {:eqri, a, b, c}), do: store(regs, c, if(read(regs, a) == b, do: 1, else: 0))

  def step(regs, {:eqrr, a, b, c}),
    do: store(regs, c, if(read(regs, a) == read(regs, b), do: 1, else: 0))

  # catch all noop

  def step(regs, _), do: regs
end

defmodule Day19 do
  @doc """
      iex> Day19.part1("#ip 3
      ...>addi 3 16 3
      ...>seti 1 6 5
      ...>seti 1 8 2
      ...>mulr 5 2 1
      ...>eqrr 1 4 1
      ...>addr 1 3 3
      ...>addi 3 1 3
      ...>addr 5 0 0
      ...>addi 2 1 2
      ...>gtrr 2 4 1
      ...>addr 3 1 3
      ...>seti 2 3 3
      ...>addi 5 1 5
      ...>gtrr 5 4 1
      ...>addr 1 3 3
      ...>seti 1 8 3
      ...>mulr 3 3 3
      ...>addi 4 2 4
      ...>mulr 4 4 4
      ...>mulr 3 4 4
      ...>muli 4 11 4
      ...>addi 1 6 1
      ...>mulr 1 3 1
      ...>addi 1 10 1
      ...>addr 4 1 4
      ...>addr 3 0 3
      ...>seti 0 0 3
      ...>setr 3 9 1
      ...>mulr 1 3 1
      ...>addr 3 1 1
      ...>mulr 3 1 1
      ...>muli 1 14 1
      ...>mulr 1 3 1
      ...>addr 4 1 4
      ...>seti 0 4 0
      ...>seti 0 0 3
      ...>")
      1968

      iex> Day19.part1("#ip 0
      ...>seti 5 0 1
      ...>seti 6 0 2
      ...>addi 0 1 0
      ...>addr 1 2 3
      ...>setr 1 0 0
      ...>seti 8 0 4
      ...>seti 9 0 5")
      6
  """
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
    |> execute()
    |> case do
      {_ip, regs, _ipr} -> hd(regs)
    end
  end

  def execute([{:ip, ipr} | instructions]) do
    execute(to_indexed_map(instructions), {0, [0, 0, 0, 0, 0, 0], ipr})
  end

  def execute(instruction_map, {ip, regs, ipr}) do
    case instruction_map[ip] do
      nil ->
        IO.inspect({ip, regs, ipr}, label: "halted")

      next_instruction ->
        regs = Device.store(regs, ipr, ip)
        new_regs = Device.step(regs, next_instruction)

        if hd(regs) != hd(new_regs) do
          IO.puts(
            "ip(#{ipr})=#{ip} #{inspect(regs)} #{inspect(next_instruction)} #{inspect(new_regs)}"
          )
        end

        ip = Device.read(new_regs, ipr) + 1
        execute(instruction_map, {ip, new_regs, ipr})
    end
  end

  defp parse_instruction(s) do
    case String.split(s, " ") do
      ["#ip", num] ->
        {:ip, String.to_integer(num)}

      [opcode | tail] ->
        List.to_tuple([String.to_existing_atom(opcode) | Enum.map(tail, &String.to_integer/1)])
    end
  end

  defp to_indexed_map(list) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.zip(list)
    |> Enum.into(%{})
  end
end
