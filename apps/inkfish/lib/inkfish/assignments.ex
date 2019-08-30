defmodule Inkfish.Assignments do
  @moduledoc """
  The Assignments context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Assignments.Assignment
  alias Inkfish.Subs.Sub

  @doc """
  Returns the list of assignments.

  ## Examples

      iex> list_assignments()
      [%Assignment{}, ...]

  """
  def list_assignments do
    Repo.all(Assignment)
  end

  @doc """
  Gets a single assignment.

  Raises `Ecto.NoResultsError` if the Assignment does not exist.

  ## Examples

      iex> get_assignment!(123)
      %Assignment{}

      iex> get_assignment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_assignment!(id) do
    Repo.one! from as in Assignment,
      where: as.id == ^id,
      left_join: teamset in assoc(as, :teamset),
      left_join: grade_columns in assoc(as, :grade_columns),
      left_join: starter in assoc(as, :starter_upload),
      left_join: solution in assoc(as, :solution_upload),
      preload: [teamset: teamset, grade_columns: grade_columns,
                starter_upload: starter, solution_upload: solution]
  end

  def list_subs_for_reg(as_id, %Inkfish.Users.Reg{} = reg),
    do: list_subs_for_reg(as_id, reg.id)

  def list_subs_for_reg(as_id, reg_id) do
    Repo.all from sub in Sub,
      where: sub.reg_id == ^reg_id and sub.assignment_id == ^as_id,
      left_join: grades in assoc(sub, :grades),
      order_by: [desc: :inserted_at],
      preload: [grades: grades]
  end

  def get_assignment_for_staff!(id) do
    Repo.one! from as in Assignment,
      where: as.id == ^id,
      left_join: teamset in assoc(as, :teamset),
      left_join: grade_columns in assoc(as, :grade_columns),
      left_join: starter in assoc(as, :starter_upload),
      left_join: solution in assoc(as, :solution_upload),
      left_join: subs in assoc(as, :subs),
      left_join: grades in assoc(subs, :grades),
      left_join: reg in assoc(subs, :reg),
      left_join: user in assoc(reg, :user),
      preload: [
        teamset: teamset,
        grade_columns: grade_columns,
        starter_upload: starter,
        solution_upload: solution,
        subs: {subs, grades: grades, reg: {reg, user: user}},
      ]
  end

  def get_assignment_path!(id) do
    Repo.one! from as in Assignment,
      where: as.id == ^id,
      inner_join: bucket in assoc(as, :bucket),
      inner_join: course in assoc(bucket, :course),
      inner_join: teamset in assoc(as, :teamset),
      left_join: starter in assoc(as, :starter_upload),
      left_join: grade_columns in assoc(as, :grade_columns),
      preload: [bucket: {bucket, course: course}, grade_columns: grade_columns,
                teamset: teamset, starter_upload: starter]
  end

  @doc """
  Creates a assignment.

  ## Examples

      iex> create_assignment(%{field: value})
      {:ok, %Assignment{}}

      iex> create_assignment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_assignment(attrs \\ %{}) do
    %Assignment{}
    |> Assignment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a assignment.

  ## Examples

      iex> update_assignment(assignment, %{field: new_value})
      {:ok, %Assignment{}}

      iex> update_assignment(assignment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_assignment(%Assignment{} = assignment, attrs) do
    assignment
    |> Assignment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Assignment.

  ## Examples

      iex> delete_assignment(assignment)
      {:ok, %Assignment{}}

      iex> delete_assignment(assignment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_assignment(%Assignment{} = assignment) do
    Repo.delete(assignment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking assignment changes.

  ## Examples

      iex> change_assignment(assignment)
      %Ecto.Changeset{source: %Assignment{}}

  """
  def change_assignment(%Assignment{} = assignment) do
    Assignment.changeset(assignment, %{})
  end


  def next_due(course_id, _user_id) do
    Repo.one from as in Assignment,
      inner_join: bucket in assoc(as, :bucket),
      where: bucket.course_id == ^course_id,
      where: as.due > fragment("now()::timestamp"),
      limit: 1
  end
end
