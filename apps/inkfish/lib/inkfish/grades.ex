defmodule Inkfish.Grades do
  @moduledoc """
  The Grades context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Grades.GradeColumn
  alias Inkfish.Autograde

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
  If this is an {:ok, gc} pair, update the score
  in the associated assignment.
  """
  def gc_update_assignment_points({:ok, gc}) do
    Inkfish.Assignments.update_assignment_points!(gc.assignment_id)
    {:ok, gc}
  end

  def gc_update_assignment_points(error) do
    error
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
    |> gc_update_assignment_points()
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
    |> gc_update_assignment_points()
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
    |> gc_update_assignment_points()
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
    Repo.one! from grade in Grade,
      where: grade.id == ^id,
      inner_join: sub in assoc(grade, :sub),
      inner_join: reg in assoc(sub, :reg),
      inner_join: reg_user in assoc(reg, :user),
      inner_join: team in assoc(sub, :team),
      left_join: team_regs in assoc(team, :regs),
      left_join: team_user in assoc(team_regs, :user),
      left_join: gc in assoc(grade, :grade_column),
      left_join: lcs in assoc(grade, :line_comments),
      left_join: user in assoc(lcs, :user),
      preload: [grade_column: gc, line_comments: {lcs, user: user},
                sub: {sub, reg: {reg, user: reg_user},
                      team: {team, regs: {team_regs, user: team_user}}}]
  end

  def get_grade_path!(id) do
    Repo.one! from grade in Grade,
      where: grade.id == ^id,
      inner_join: sub in assoc(grade, :sub),
      inner_join: team in assoc(sub, :team),
      left_join: regs in assoc(team, :regs),
      left_join: user in assoc(regs, :user),
      inner_join: as in assoc(sub, :assignment),
      inner_join: bucket in assoc(as, :bucket),
      inner_join: course in assoc(bucket, :course),
      inner_join: gc in assoc(grade, :grade_column),
      preload: [sub: {sub, assignment: {as, bucket: {bucket, course: course}},
                           team: {team, regs: {regs, user: user}}},
                grade_column: gc]
  end

  def get_grade_for_autograding!(id) do
    Repo.one! from grade in Grade,
      where: grade.id == ^id,
      inner_join: sub in assoc(grade, :sub),
      inner_join: up in assoc(sub, :upload),
      inner_join: as in assoc(sub, :assignment),
      inner_join: gc in assoc(grade, :grade_column),
      left_join: gc_up in assoc(gc, :upload),
      preload: [sub: {sub, assignment: as, upload: up},
                grade_column: {gc, upload: gc_up}]
  end

  def get_grade_by_log_uuid(uuid) do
    Repo.one from grade in Grade,
      where: grade.log_uuid == ^uuid,
      inner_join: gc in assoc(grade, :grade_column),
      preload: [grade_column: gc]
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

  def create_autograde(sub_id, gcol_id) do
    attrs = %{
      grade_column_id: gcol_id,
      sub_id: sub_id,
    }
    {:ok, grade} = create_grade(attrs)
    {:ok, uuid} = Autograde.start(grade.id)
    update_grade(grade, %{log_uuid: uuid})
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

    Inkfish.Subs.calc_sub_score!(grade.sub_id)
    {:ok, %{grade|grade_column: gcol}}
  end
end
