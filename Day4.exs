#! /usr/bin/env elixir

defmodule WorkerDay do
  defstruct id: nil,
            date: {nil, nil},
            events: []

  def merge(a, b) do
    %WorkerDay{a | id: a.id || b.id, events: (a.events ++ b.events) |> Enum.sort()}
  end

  def sleep_minutes(%WorkerDay{events: events}) do
    events
    |> Enum.reverse()
    |> Enum.reduce(0, fn
      {minute, :wake}, sleep ->
        sleep + minute

      {minute, :sleep}, sleep ->
        sleep - minute
    end)
  end

  def best_minute(days) do
    days
    #    |> IO.inspect(label: "Days")
    |> Enum.reduce(%{}, fn day, map ->
      day.events
      |> Enum.chunk_every(2)
      |> Enum.reduce(map, fn [{sleep, _}, {wake, _}], map ->
        sleep..(wake - 1)
        |> Enum.reduce(map, fn minute, map ->
          Map.update(map, minute, 1, &(&1 + 1))
        end)
      end)
    end)
    |> Enum.to_list()
    |> Enum.sort()
    |> case do
      [] -> {0, 0}
      minutes -> Enum.max_by(minutes, fn {_, count} -> count end)
    end
  end
end

defmodule Day4 do
  defp trim_map(input) do
    input
    |> Stream.map(fn string -> string |> String.trim() end)
  end

  def guard_times_minute(input) do
    {_sleep_minutes, days} =
      input
      |> trim_map()
      |> Stream.map(&parse_entry/1)
      |> Enum.reduce(%{}, fn entry, map ->
        Map.update(map, entry.date, entry, fn prev ->
          WorkerDay.merge(entry, prev)
        end)
      end)
      |> Enum.reduce(%{}, fn {_, day}, map ->
        sleep_minutes = WorkerDay.sleep_minutes(day)

        Map.update(map, day.id, {sleep_minutes, [day]}, fn {prev_minutes, prev} ->
          {prev_minutes + sleep_minutes, [day | prev]}
        end)
      end)
      |> Enum.reduce({0, []}, fn {_, {minutes, _} = x}, {acc_minutes, _} = acc ->
        if minutes > acc_minutes do
          x
        else
          acc
        end
      end)

    {minute, _count} = WorkerDay.best_minute(days)
    minute * hd(days).id
  end

  def strategy2_guard_times_minute(input) do
    {id, {_, {minute, _count}, _days}} =
      input
      |> trim_map()
      |> Stream.map(&parse_entry/1)
      |> Enum.reduce(%{}, fn entry, map ->
        Map.update(map, entry.date, entry, fn prev ->
          WorkerDay.merge(entry, prev)
        end)
      end)
      |> Enum.reduce(%{}, fn {_, day}, map ->
        sleep_minutes = WorkerDay.sleep_minutes(day)

        Map.update(map, day.id, {sleep_minutes, [day]}, fn {prev_minutes, prev} ->
          {prev_minutes + sleep_minutes, [day | prev]}
        end)
      end)
      #      |> IO.inspect(label: "By Worker:")
      |> Enum.map(fn {k, {minutes, days}} ->
        {k, {minutes, WorkerDay.best_minute(days), days}}
      end)
      #      |> IO.inspect(label: "By Worker Including best minutes:")
      |> Enum.max_by(fn {_, {_, {_, count}, _}} -> count end)

    minute * id
  end

  defp parse_entry(line) do
    <<"[", date_string::binary-size(16), "] ", rest::binary>> = line
    {:ok, datetime, _} = DateTime.from_iso8601(<<date_string::binary, ":00Z"::utf8>>)
    minute = datetime.minute
    {:ok, date} = DateTime.from_unix(DateTime.to_unix(datetime) + 60 * 60)
    key = {date.month, date.day}

    result = %WorkerDay{date: key}

    case rest do
      <<"Guard #", id::binary>> ->
        {id, _} = Integer.parse(id)
        %WorkerDay{result | id: id}

      <<"falls", _::binary>> ->
        %WorkerDay{result | events: [{minute, :sleep}]}

      _ ->
        %WorkerDay{result | events: [{minute, :wake}]}
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      import Day4

      def string_to_stream(input) do
        {:ok, io} = StringIO.open(input)
        IO.stream(io, :line)
      end

      def test_stream do
        string_to_stream("""
        [1518-11-01 00:00] Guard #10 begins shift
        [1518-11-01 00:05] falls asleep
        [1518-11-01 00:25] wakes up
        [1518-11-01 00:30] falls asleep
        [1518-11-01 00:55] wakes up
        [1518-11-01 23:58] Guard #99 begins shift
        [1518-11-02 00:40] falls asleep
        [1518-11-02 00:50] wakes up
        [1518-11-03 00:05] Guard #10 begins shift
        [1518-11-03 00:24] falls asleep
        [1518-11-03 00:29] wakes up
        [1518-11-04 00:02] Guard #99 begins shift
        [1518-11-04 00:36] falls asleep
        [1518-11-04 00:46] wakes up
        [1518-11-05 00:03] Guard #99 begins shift
        [1518-11-05 00:45] falls asleep
        [1518-11-05 00:55] wakes up
        """)
      end

      test "Part 1" do
        assert guard_times_minute(test_stream()) == 10 * 24
      end

      test "Part 2" do
        assert strategy2_guard_times_minute(test_stream()) == 99 * 45
      end
    end

  [input_file] ->
    input_file
    |> File.stream!([], :line)
    |> Day4.guard_times_minute()
    |> IO.inspect(label: "Result Part 1")

    input_file
    |> File.stream!([], :line)
    |> Day4.strategy2_guard_times_minute()
    |> IO.inspect(label: "Result Part 2")

  _ ->
    IO.puts(:stderr, "Usage: #{Path.basename(__ENV__.file)} [--test | filename]")
    System.halt(1)
end
