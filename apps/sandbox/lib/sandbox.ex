defmodule Sandbox do
  @moduledoc """
  Documentation for Sandbox.
  """

  @doc """
  Extract an archive file to a target location.

  Avoids zip bombs and removes unsafe symlinks.
  """
  def extract_archive(path, target, max_size \\ "10M") do
    Sandbox.Archive.safe_extract(path, target, max_size)
  end
end
