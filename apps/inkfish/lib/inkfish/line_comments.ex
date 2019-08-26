defmodule Inkfish.LineComments do
  @moduledoc """
  The LineComments context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.LineComments.LineComment

  @doc """
  Returns the list of line_comments.

  ## Examples

      iex> list_line_comments()
      [%LineComment{}, ...]

  """
  def list_line_comments do
    Repo.all(LineComment)
    |> preload(:user)
  end

  @doc """
  Gets a single line_comment.

  Raises `Ecto.NoResultsError` if the Line comment does not exist.

  ## Examples

      iex> get_line_comment!(123)
      %LineComment{}

      iex> get_line_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_line_comment!(id) do
    Repo.one from lc in LineComment,
      where: lc.id == ^id,
      preload: [:user]
  end

  @doc """
  Creates a line_comment.

  ## Examples

      iex> create_line_comment(%{field: value})
      {:ok, %LineComment{}}

      iex> create_line_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_line_comment(attrs \\ %{}) do
    lc = %LineComment{}
    |> LineComment.changeset(attrs)
    |> Repo.insert()

    case lc do
      {:ok, lc} ->
        {:ok, Repo.preload(lc, :user)}
      error ->
        error
    end
  end

  @doc """
  Updates a line_comment.

  ## Examples

      iex> update_line_comment(line_comment, %{field: new_value})
      {:ok, %LineComment{}}

      iex> update_line_comment(line_comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_line_comment(%LineComment{} = line_comment, attrs) do
    line_comment
    |> LineComment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a LineComment.

  ## Examples

      iex> delete_line_comment(line_comment)
      {:ok, %LineComment{}}

      iex> delete_line_comment(line_comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_line_comment(%LineComment{} = line_comment) do
    Repo.delete(line_comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking line_comment changes.

  ## Examples

      iex> change_line_comment(line_comment)
      %Ecto.Changeset{source: %LineComment{}}

  """
  def change_line_comment(%LineComment{} = line_comment) do
    LineComment.changeset(line_comment, %{})
  end
end
