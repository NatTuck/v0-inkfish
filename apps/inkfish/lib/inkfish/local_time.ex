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
end
