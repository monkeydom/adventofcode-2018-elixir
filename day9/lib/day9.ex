defmodule Day9 do
  defstruct scores: [],
            current: 0,
            marbles: [0],
            player_count: 0,
            last_played_marble: 0

  def new(player_count) do
    %Day9{scores: 1..player_count |> Enum.map(fn _ -> [] end), player_count: player_count}
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

        iex> Day9.marble_game(465,71498)
        383475
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
    |> IO.inspect(label: "End")
    |> case do
        %Day9{scores: scores} -> Enum.map(scores, fn scorelist -> Enum.sum(scorelist) end)
      end
    |> Enum.max()
  end

  def marble_game_step(marble, %Day9{current: current} = state) do
    state = %Day9{state | last_played_marble: marble}

    case rem(marble, 23) do
      0 ->
        player = rem(marble - 1, state.player_count)
        current = rem(state.current + length(state.marbles) - 7, length(state.marbles))
        {taken, marbles} = List.pop_at(state.marbles, current)

        %Day9{
          state
          | scores: List.update_at(state.scores, player, fn t -> [taken, marble | t] end),
            current: current,
            marbles: marbles
        }

      _ ->
        current = rem(state.current + 1, length(state.marbles)) + 1

        %Day9{
          state
          | current: current,
            marbles: List.insert_at(state.marbles, current, marble)
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


