# start with mix run <filename>

IO.inspect(
  :timer.tc(fn ->
    Day19.part1("""
    #ip 3
    addi 3 16 3
    seti 1 6 5
    seti 1 8 2
    mulr 5 2 1
    eqrr 1 4 1
    addr 1 3 3
    addi 3 1 3
    addr 5 0 0
    addi 2 1 2
    gtrr 2 4 1
    addr 3 1 3
    seti 2 3 3
    addi 5 1 5
    gtrr 5 4 1
    addr 1 3 3
    seti 1 8 3
    mulr 3 3 3
    addi 4 2 4
    mulr 4 4 4
    mulr 3 4 4
    muli 4 11 4
    addi 1 6 1
    mulr 1 3 1
    addi 1 10 1
    addr 4 1 4
    addr 3 0 3
    seti 0 0 3
    setr 3 9 1
    mulr 1 3 1
    addr 3 1 1
    mulr 3 1 1
    muli 1 14 1
    mulr 1 3 1
    addr 4 1 4
    seti 0 4 0
    seti 0 0 3
    """)
  end)
)


IO.inspect(
  :timer.tc(fn ->
    Day19.part2("""
    #ip 3
    addi 3 16 3
    seti 1 6 5
    seti 1 8 2
    mulr 5 2 1
    eqrr 1 4 1
    addr 1 3 3
    addi 3 1 3
    addr 5 0 0
    addi 2 1 2
    gtrr 2 4 1
    addr 3 1 3
    seti 2 3 3
    addi 5 1 5
    gtrr 5 4 1
    addr 1 3 3
    seti 1 8 3
    mulr 3 3 3
    addi 4 2 4
    mulr 4 4 4
    mulr 3 4 4
    muli 4 11 4
    addi 1 6 1
    mulr 1 3 1
    addi 1 10 1
    addr 4 1 4
    addr 3 0 3
    seti 0 0 3
    setr 3 9 1
    mulr 1 3 1
    addr 3 1 1
    mulr 3 1 1
    muli 1 14 1
    mulr 1 3 1
    addr 4 1 4
    seti 0 4 0
    seti 0 0 3
    """)
  end)
)


IO.inspect(
  :timer.tc(fn ->
    Day19.part1("""
    #ip 3
    addi 3 16 3
    seti 1 6 5
    seti 1 8 2
    mulr 5 2 1
    eqrr 1 4 1
    addr 1 3 3
    addi 3 1 3
    addr 5 0 0
    addi 2 1 2
    gtrr 2 4 1
    addr 3 1 3
    seti 2 3 3
    addi 5 1 5
    gtrr 5 4 1
    addr 1 3 3
    seti 1 8 3
    mulr 3 3 3
    addi 4 2 4
    mulr 4 4 4
    mulr 3 4 4
    muli 4 11 4
    addi 1 6 1
    mulr 1 3 1
    addi 1 10 1
    addr 4 1 4
    addr 3 0 3
    seti 0 0 3
    setr 3 9 1
    mulr 1 3 1
    addr 3 1 1
    mulr 3 1 1
    muli 1 14 1
    mulr 1 3 1
    addr 4 1 4
    seti 0 4 0
    seti 0 0 3
    """, [2400, 1, 8837, 7, 10551378, 1194])
  end)
)


# [2400, 1, 8837, 7, 10551378, 1194]