#! /usr/bin/env elixir

defmodule Day5 do

  def react_polymer(input) do
      input
      |> Enum.chunk_every(10)
  end

end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day5Test do
      use ExUnit.Case

      import Day5

      def string_to_stream(input) do
        {:ok, io} = StringIO.open(input)
        IO.stream(io, 10)
      end

      def test_stream do
        string_to_stream("""
dabAcCaCBAcCcaDA
""")
      end

      test "Part 1" do
        assert react_polymer(test_stream()) == "dabCBAcaDA"
      end

#      test "Part 2" do
#        assert strategy2_guard_times_minute(test_stream()) == 99 * 45
#      end
    end

  [input_file] ->
    input_file
    |> File.stream!([],10)
    |> Day5.react_polymer()
    |> IO.inspect(label: "Result Part 1")


  _ ->
    IO.puts(:stderr, "Usage: #{Path.basename(__ENV__.file)} [--test | filename]")
    System.halt(1)
end
