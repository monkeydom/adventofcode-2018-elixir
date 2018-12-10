defmodule Day1 do
  def final_frequency(input) do
    input
    |> String.split("\n", trim: true)
    |> sum_lines()
  end

  defp sum_lines(lines) do
    lines
  end
end

ExUnit.start()

defmodule Day1Test do
  use ExUnit.Case

  import Day1

  test "final_frequency" do
    assert final_frequency("""
           +1
           +1
           +1
           """) == 3
  end
end
