defmodule Inkfish.Autograde.TapTest do
  use ExUnit.Case

  alias Inkfish.Autograde.Tap

  @tap_good """
  1..8
  ok 1 - square binary executable
  ok 2 - sq(0)
  ok 3 - sq(2)
  ok 4 - sq(10)
  ok 5 - cube binary executable
  ok 6 - cu(0)
  ok 7 - cu(3)
  ok 8 - cu(10)
  """

  test "handles good TAP", _ do
    assert Tap.score(@tap_good) == {:ok, {8, 8}}
  end

  @tap_comment """
  1..8
  ok 1 - square binary executable
  # This is a comment
  ok 2 - sq(0)
  ok 3 - sq(2)
  ok 4 - sq(10)
  ok 5 - cube binary executable
  ok 6 - cu(0)
  ok 7 - cu(3)
  ok 8 - cu(10)
  """

  test "handles good TAP with comment", _ do
    assert Tap.score(@tap_comment) == {:ok, {8, 8}}
  end

  @tap_bad_line """
  1..8
  ok 1 - square binary executable
  ok 2 - sq(0)
  ok three - sq(2)
  ok 4 - sq(10)
  ok 5 - cube binary executable
  ok 6 - cu(0)
  ok 7 - cu(3)
  ok 8 - cu(10)
  """

  test "handles TAP with bad line", _ do
    assert Tap.score(@tap_bad_line) == {:ok, {0, 1}}
  end

  @tap_missed_test """
  1..8
  ok 1 - square binary executable
  ok 2 - sq(0)
  ok 4 - sq(10)
  ok 5 - cube binary executable
  ok 6 - cu(0)
  ok 7 - cu(3)
  ok 8 - cu(10)
  """

  test "handles TAP with missing test", _ do
    assert Tap.score(@tap_missed_test) == {:ok, {7, 8}}
  end

  @tap_bad_count """
  1..goat
  ok 1 - square binary executable
  ok 2 - sq(0)
  ok 4 - sq(10)
  ok 5 - cube binary executable
  ok 6 - cu(0)
  ok 7 - cu(3)
  ok 8 - cu(10)
  """

  test "handles TAP with bad count", _ do
    assert Tap.score(@tap_bad_count) == {:ok, {0, 1}}
  end

  @tap_extra_tests """
  1..6
  ok 1 - square binary executable
  ok 2 - sq(0)
  ok 3 - sq(2)
  ok 4 - sq(10)
  ok 5 - cube binary executable
  ok 6 - cu(0)
  ok 7 - cu(3)
  ok 8 - cu(10)
  """

  test "handles TAP with extra tests", _ do
    assert Tap.score(@tap_extra_tests) == {:ok, {6, 6}}
  end
end
