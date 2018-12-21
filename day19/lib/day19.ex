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
  
  require Device # for the atoms
  
  @doc """

      iex> Day19.part1("#ip 0
      ...>seti 5 0 1
      ...>seti 6 0 2
      ...>addi 0 1 0
      ...>addr 1 2 3
      ...>setr 1 0 0
      ...>seti 8 0 4
      ...>seti 9 0 5")
      6

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
      ...>", [990, 1, 1, 7, 978, 978])
      1968


  """
  def part1(input, initial_registers \\ [0,0,0,0,0,0]) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
    |> execute(initial_registers)
    |> case do
      {_ip, regs, _ipr} -> hd(regs)
    end
  end
  
  @doc """

      iex> Day19.part2([0,0,0,0,0,0])
      1968
  """
  
  def part2(initial_registers \\ [0,0,0,0,0,0]) do
    elixired(List.to_tuple(initial_registers))
  end

  defp elixired({_,_,_,ip,_,_} = regs) when ip > 35, do: {:halted, regs}

  defp elixired({r0,r1,r2,ip=0,r4,r5} = _regs) do
# addi 3 16 3
    ip = ip + 16
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=1,r4,r5} = _regs) do
# seti 1 6 5
    r5 = 1
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=2,r4,r5} = _regs) do
# seti 1 8 2
    r2 = 1
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=3,r4,r5} = _regs) do
# mulr 5 2 1
    r1 = r5 * r2
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=4,r4,r5} = _regs) do
# eqrr 1 4 1 if r1 == r4 => r1
    r1 = equal(r1,r4)
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=5,r4,r5} = _regs) do
# addr 1 3 3 skip next if equal 
    ip = r1 + ip
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=6,r4,r5} = _regs) do
# addi 3 1 3 skip next instruction
    ip = ip + 1
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=7,r4,r5} = _regs) do
# addr 5 0 0 # this is the part where it increments
    r0 = r0 + r5
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=8,r4,r5} = _regs) do
# addi 2 1 2
    r2 = r2 + 1
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=9,r4,r5} = _regs) do
# gtrr 2 4 1 if r2 > r4 => r1
    r1 = greater(r2,r4)
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=10,r4,r5} = _regs) do
# addr 3 1 3 skip next if equal 
    ip = r1 + ip
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=11,r4,r5} = _regs) do
# seti 2 3 3	
    ip = 2 
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=12,r4,r5} = _regs) do
# addi 5 1 5
    r5 = r5 + 1
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=13,r4,r5} = _regs) do
# gtrr 5 4 1 if r5 > r4 => r1
    r1 = greater(r5,r4)
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=14,r4,r5} = _regs) do
# addr 1 3 3  
    ip = r1 + ip
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=15,r4,r5} = _regs) do
# seti 1 8 3 jump to 2
    ip = 1
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=16,r4,r5} = _regs) do
# mulr 3 3 3 jump to 
    ip = ip * ip 
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=17,r4,r5} = _regs) do
# addi 4 2 4
    r4 = r4 + 2
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=18,r4,r5} = _regs) do
# mulr 4 4 4
    r4 = r4 * r4
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=19,r4,r5} = _regs) do
# mulr 3 4 4
    r4 = ip * r4
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=20,r4,r5} = _regs) do
# muli 4 11 4
    r4 = 11 * r4
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=21,r4,r5} = _regs) do
# addi 1 6 1
    r1 = 6 + r1
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=22,r4,r5} = _regs) do
# mulr 1 3 1
    r1 = ip * r1
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=23,r4,r5} = _regs) do
# addi 1 10 1
    r1 = 10 + r1
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=24,r4,r5} = _regs) do
# addr 4 1 4
    r4 = r1 + r4
    ip = ip + 1
    elixired({r0,r1,r2,ip,r4,r5})
  end

  defp elixired({r0,r1,r2,ip=25,r4,r5} = _regs) do
# addr 3 0 3
    ip = r0 + ip
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=26,r4,r5} = _regs) do
# seti 0 0 3
    ip = r0 
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

# only used when r0 == 1 initially

  defp elixired({r0,r1,r2,ip=27,r4,r5} = _regs) do
# setr 3 9 1
    r1 = ip 
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=28,r4,r5} = _regs) do
# mulr 1 3 1
    r1 = ip * r1 
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=29,r4,r5} = _regs) do
# addr 3 1 1
    r1 = ip + r1 
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=30,r4,r5} = _regs) do
# mulr 3 1 1
    r1 = ip * r1 
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=31,r4,r5} = _regs) do
# muli 1 14 1
    r1 = r1 * 14 
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=32,r4,r5} = _regs) do
# mulr 1 3 1
    r1 = ip * r1
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=33,r4,r5} = _regs) do
# addr 4 1 4
    r4 = r1 + r4 
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=34,r4,r5} = _regs) do
# seti 0 4 0
    r0 = 0 
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  defp elixired({r0,r1,r2,ip=35,r4,r5} = _regs) do
# seti 0 0 3
    ip = 0 
    ip = ip + 1
    {r0,r1,r2,ip,r4,r5} |> elixired()
  end

  
  defp equal(x,x), do: 1
  defp equal(_,_), do: 0

  defp greater(a,b) when a > b, do: 1
  defp greater(_,_), do: 0


  def execute([{:ip, ipr} | instructions], initial_registers) do
    execute(to_indexed_map(instructions), {Enum.at(initial_registers, ipr), initial_registers, ipr})
  end

  def execute(instruction_map, {ip, regs, ipr}) do
    case instruction_map[ip] do
      nil ->
        IO.inspect({ip, regs, ipr}, label: "halted")

      next_instruction ->
        regs = Device.store(regs, ipr, ip)
        new_regs = Device.step(regs, next_instruction)

        if hd(regs) != hd(new_regs) or ip == 0 do
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
