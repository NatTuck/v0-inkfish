defmodule Inkfish.Grades do
  @moduledoc """
  The Grades context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Grades.Grader

  @doc """
  Returns the list of graders.

  ## Examples

      iex> list_graders()
      [%Grader{}, ...]

  """
  def list_graders do
    Repo.all(Grader)
  end

  @doc """
  Gets a single grader.

  Raises `Ecto.NoResultsError` if the Grader does not exist.

  ## Examples

      iex> get_grader!(123)
      %Grader{}

      iex> get_grader!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grader!(id) do
    Repo.one! from gr in Grader,
      where: gr.id == ^id,
      left_join: upload in assoc(gr, :upload),
      preload: [upload: upload]
  end

  def get_grader_path!(id) do
    Repo.one! from gr in Grader,
      where: gr.id == ^id,
      inner_join: as in assoc(gr, :assignment),
      inner_join: bucket in assoc(as, :bucket),
      inner_join: course in assoc(bucket, :course),
      preload: [assignment: {as, bucket: {bucket, course: course}}]
  end

  @doc """
  Creates a grader.

  ## Examples

      iex> create_grader(%{field: value})
      {:ok, %Grader{}}

      iex> create_grader(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grader(attrs \\ %{}) do
    %Grader{}
    |> Grader.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a grader.

  ## Examples

      iex> update_grader(grader, %{field: new_value})
      {:ok, %Grader{}}

      iex> update_grader(grader, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grader(%Grader{} = grader, attrs) do
    grader
    |> Grader.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Grader.

  ## Examples

      iex> delete_grader(grader)
      {:ok, %Grader{}}

      iex> delete_grader(grader)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grader(%Grader{} = grader) do
    Repo.delete(grader)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grader changes.

  ## Examples

      iex> change_grader(grader)
      %Ecto.Changeset{source: %Grader{}}

  """
  def change_grader(%Grader{} = grader) do
    Grader.changeset(grader, %{})
  end
end
