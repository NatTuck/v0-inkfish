defmodule Sandbox do
  @moduledoc """
  Documentation for Sandbox.
  """

  @doc """
  Create a temporary directory with a maximum size.

  returns {:ok, path} or {:error, msg}
  """
  def make_tempfs(max_size) do
    Sandbox.TempFs.make_tempfs(max_size)
  end

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
