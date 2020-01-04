defmodule Inkfish.Autograde.Tap do
  @doc """
  Parses TAP as output by Perl's Test::Simple.

  Returns {:ok, {passed, count}} on success.

  If it gets confused, returns {:ok, {0, 1}}.
  """
  def score(text) do
    try do
      score!(text)
    rescue
      _err ->
        #IO.inspect({__MODULE__, _err})
        {:ok, {0, 1}}
    end
  end

  @doc """
  Parses TAP as output by Perl's Test::Simple.

  Returns {:ok, {passed, count}} on success.

  Crashes on failure.
  """
  def score!(text) do
    [predec | test_lines] = text
    |> String.split("\n")
    |> Enum.filter(fn line ->
      (line =~ ~r/^ok/ ||
       line =~ ~r/^not/ ||
       line =~ ~r/^\d+\.\.\d+$/)
    end)

    [_, "1", total] = Regex.run(~r/^(\d+)\.\.(\d+)$/, predec)
    {total, _} = Integer.parse(total)

    tests = test_lines
    |> Enum.map(fn line ->
      pat = ~r/^(ok|not ok)\s+(\d+)\s+-\s+(.*)$/
      [_, ok, num, _text] = Regex.run(pat, line)
      {num, _} = Integer.parse(num)
      {num, ok == "ok"}
    end)
    |> Enum.into(%{})

    passed = Enum.reduce 1..total, 0, fn (ii, acc) ->
      if tests[ii] do
        acc + 1
      else
        acc
      end
    end

    {:ok, {passed, total}}
  end
end
