defmodule Inkfish.Assignments do
  @moduledoc """
  The Assignments context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Assignments.Assignment
  alias Inkfish.Subs.Sub
  alias Inkfish.Users.Reg
  alias Inkfish.Teams.Team
  alias Inkfish.Grades.Grade

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

  def list_subs_for_reg(as_id, %Reg{} = reg),
    do: list_subs_for_reg(as_id, reg.id)

  def list_subs_for_reg(as_id, reg_id) do
    teams = Repo.all from tt in Team,
      inner_join: teamset in assoc(tt, :teamset),
      left_join: asgs in assoc(teamset, :assignments),
      left_join: members in assoc(tt, :team_members),
      where: members.reg_id == ^reg_id,
      where: asgs.id == ^as_id
    team_ids = Enum.map teams, &(&1.id)

    Repo.all from sub in Sub,
      where: sub.assignment_id == ^as_id,
      where: sub.reg_id == ^reg_id or sub.team_id in ^team_ids,
      left_join: grades in assoc(sub, :grades),
      order_by: [desc: :inserted_at],
      preload: [grades: grades]
  end

  def list_active_subs(%Assignment{} = as) do
    Repo.all from sub in Sub,
      where: sub.assignment_id == ^as.id,
      where: sub.active,
      left_join: grades in assoc(sub, :grades),
      left_join: reg in assoc(sub, :reg),
      left_join: user in assoc(reg, :user),
      left_join: gcol in assoc(grades, :grade_column),
      preload: [grades: {grades, grade_column: gcol},
                reg: {reg, user: user}]
  end

  def get_assignment_for_staff!(id) do
    Repo.one! from as in Assignment,
      where: as.id == ^id,
      left_join: teamset in assoc(as, :teamset),
      left_join: grade_columns in assoc(as, :grade_columns),
      left_join: starter in assoc(as, :starter_upload),
      left_join: solution in assoc(as, :solution_upload),
      preload: [
        teamset: teamset,
        grade_columns: grade_columns,
        starter_upload: starter,
        solution_upload: solution,
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

  def update_assignment_points!(%Assignment{} = as) do
    update_assignment_points!(as.id)
  end

  def update_assignment_points!(as_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:as0, fn (_,_) ->
      as = Repo.one from as in Assignment,
        where: as.id == ^as_id,
        left_join: gcs in assoc(as, :grade_columns),
        preload: [grade_columns: gcs]
      {:ok, as}
    end)
    |> Ecto.Multi.update(:as1, fn %{as0: as} ->
      points = Enum.reduce as.grade_columns, Decimal.new("0.0"), fn (gc, acc) ->
        Decimal.add(acc, gc.points)
      end
      Ecto.Changeset.change(as, points: points)
    end)
    |> Repo.transaction()
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

  @doc """
  Creates a fake sub for each team in the associated teamset,
  containing a single text file for grading.
  """
  def create_fake_subs!(as, owner) do
    {:ok, upload} = Inkfish.Uploads.create_fake_upload(owner)
    teams = Inkfish.Teams.list_teams(as.teamset_id)

    Enum.each teams, fn team ->
      submitter = hd(team.regs)
      attrs = %{
        assignment_id: as.id,
        reg_id: submitter.id,
        team_id: team.id,
        upload_id: upload.id,
        hours_spent: "0.0",
      }
      {:ok, _sub} = Inkfish.Subs.create_sub(attrs)
    end
  end

  @doc """
  Assigns staff grading tasks for submissions to this
  assignment.
  """
  def assign_grading_tasks(as = %Assignment{}) do
    assign_grading_tasks(as.id)
  end

  def assign_grading_tasks(as_id) do
    as = get_assignment_path!(as_id)

    # Remove grading tasks for inactive subs.
    GradingTasks.unassign_inactive_subs(as)

    # Process active subs.
    GradingTasks.assign_grading_tasks(as)
  end

  def list_grading_tasks(as) do
    Repo.all from grade in Grade,
      inner_join: sub in assoc(grade, :sub),
      inner_join: asg in assoc(sub, :assignment),
      inner_join: reg in assoc(sub, :reg),
      inner_join: user in assoc(reg, :user),
      inner_join: gcol in assoc(grade, :grade_column),
      left_join: grader in assoc(grade, :grader),
      where: asg.id == ^as.id,
      where: gcol.kind == "feedback",
      where: sub.active,
      where: reg.is_student,
      preload: [sub: {sub, assignment: asg, reg: {reg, user: user}},
                grade_column: gcol, grader: grader]
  end
end
