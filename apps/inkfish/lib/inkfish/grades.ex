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

  alias Inkfish.Grades.Grade

  @doc """
  Returns the list of grades.

  ## Examples

      iex> list_grades()
      [%Grade{}, ...]

  """
  def list_grades do
    Repo.all(Grade)
  end

  @doc """
  Gets a single grade.

  Raises `Ecto.NoResultsError` if the Grade does not exist.

  ## Examples

      iex> get_grade!(123)
      %Grade{}

      iex> get_grade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grade!(id), do: Repo.get!(Grade, id)

  @doc """
  Creates a grade.

  ## Examples

      iex> create_grade(%{field: value})
      {:ok, %Grade{}}

      iex> create_grade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grade(attrs \\ %{}) do
    %Grade{}
    |> Grade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a grade.

  ## Examples

      iex> update_grade(grade, %{field: new_value})
      {:ok, %Grade{}}

      iex> update_grade(grade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grade(%Grade{} = grade, attrs) do
    grade
    |> Grade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Grade.

  ## Examples

      iex> delete_grade(grade)
      {:ok, %Grade{}}

      iex> delete_grade(grade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grade(%Grade{} = grade) do
    Repo.delete(grade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grade changes.

  ## Examples

      iex> change_grade(grade)
      %Ecto.Changeset{source: %Grade{}}

  """
  def change_grade(%Grade{} = grade) do
    Grade.changeset(grade, %{})
  end
end
