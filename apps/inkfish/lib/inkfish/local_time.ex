defmodule Inkfish.LocalTime do
  def now() do
    {:ok, now} = :calendar.local_time()
    |> NaiveDateTime.from_erl()
    now
  end

  def today() do
    now()
    |> NaiveDateTime.to_date()
  end

  def in_days(nn) do
    seconds_per_day = 24 * 60 * 60
    now()
    |> NaiveDateTime.add(nn * seconds_per_day)
  end
end
