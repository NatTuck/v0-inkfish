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

  @doc """
  Clones a git repository to a target location.

  Limits total size.
  """
  def git_clone(url, dst, max_size \\ "10M") do
    Sandbox.Git.clone(url, dst, max_size)
  end
end
