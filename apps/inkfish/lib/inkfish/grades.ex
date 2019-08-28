defmodule Inkfish.Grades do
  @moduledoc """
  The Grades context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Grades.GradeColumn

  @doc """
  Returns the list of grade_columns.

  ## Examples

      iex> list_grade_columns()
      [%GradeColumn{}, ...]

  """
  def list_grade_columns do
    Repo.all(GradeColumn)
  end

  @doc """
  Gets a single grade_column.

  Raises `Ecto.NoResultsError` if the GradeColumn does not exist.

  ## Examples

      iex> get_grade_column!(123)
      %GradeColumn{}

      iex> get_grade_column!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grade_column!(id) do
    Repo.one! from gr in GradeColumn,
      where: gr.id == ^id,
      left_join: upload in assoc(gr, :upload),
      preload: [upload: upload]
  end

  def get_grade_column_path!(id) do
    Repo.one! from gr in GradeColumn,
      where: gr.id == ^id,
      inner_join: as in assoc(gr, :assignment),
      inner_join: bucket in assoc(as, :bucket),
      inner_join: course in assoc(bucket, :course),
      preload: [assignment: {as, bucket: {bucket, course: course}}]
  end

  @doc """
  Creates a grade_column.

  ## Examples

      iex> create_grade_column(%{field: value})
      {:ok, %GradeColumn{}}

      iex> create_grade_column(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grade_column(attrs \\ %{}) do
    %GradeColumn{}
    |> GradeColumn.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a grade_column.

  ## Examples

      iex> update_grade_column(grade_column, %{field: new_value})
      {:ok, %GradeColumn{}}

      iex> update_grade_column(grade_column, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grade_column(%GradeColumn{} = grade_column, attrs) do
    grade_column
    |> GradeColumn.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a GradeColumn.

  ## Examples

      iex> delete_grade_column(grade_column)
      {:ok, %GradeColumn{}}

      iex> delete_grade_column(grade_column)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grade_column(%GradeColumn{} = grade_column) do
    Repo.delete(grade_column)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grade_column changes.

  ## Examples

      iex> change_grade_column(grade_column)
      %Ecto.Changeset{source: %Grade_Column{}}

  """
  def change_grade_column(%GradeColumn{} = grade_column) do
    GradeColumn.changeset(grade_column, %{})
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
  def get_grade!(id) do
    Repo.get!(Grade, id)
    |> Repo.preload([:grade_column, {:line_comments, [:user]}])
  end

  def get_grade_path!(id) do
    Repo.one! from grade in Grade,
      where: grade.id == ^id,
      inner_join: sub in assoc(grade, :sub),
      inner_join: as in assoc(sub, :assignment),
      inner_join: bucket in assoc(as, :bucket),
      inner_join: course in assoc(bucket, :course),
      preload: [sub: {sub, assignment: {as, bucket: {bucket, course: course}}}]
  end

  @doc """
  Creates a grade.

  ## Examples

      iex> create_grade(%{field: value})
      {:ok, %Grade{}}

      iex> create_grade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grade(attrs \\ %{}) do
    result = %Grade{}
    |> Grade.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:score]},
      conflict_target: [:sub_id, :grade_column_id])

    case result do
      {:ok, grade} ->
        {:ok, Repo.preload(grade, [:grader])}
      error ->
        error
    end
  end

  def create_null_grade(sub_id, grade_column_id) do
    attrs = %{
      sub_id: sub_id,
      grade_column_id: grade_column_id,
      score: nil,
    }
    create_grade(attrs)
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


  def update_feedback_score(grade_id) do
    grade = get_grade!(grade_id)
    gcol  = get_grade_column!(grade.grade_column_id)
    delta = Enum.reduce grade.line_comments, Decimal.new("0.0"), fn (lc, acc) ->
      Decimal.add(lc.points, acc)
    end

    score = Decimal.add(gcol.base, delta)
    {:ok, grade} = update_grade(grade, %{score: score})
    {:ok, %{grade|grade_column: gcol}}
  end
end
