defmodule Inkfish.Subs do
  @moduledoc """
  The Subs context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Subs.Sub
  alias Inkfish.Users.Reg
  alias Inkfish.Teams
  alias Inkfish.Teams.Team
  alias Inkfish.LocalTime

  alias Inkfish.Grades

  def make_zero_sub(as) do
    %Sub{
      active: true,
      assignment: as,
      score: Decimal.new("0.0"),
    }
  end

  @doc """
  Returns the list of subs.

  ## Examples

      iex> list_subs()
      [%Sub{}, ...]

  """
  def list_subs do
    Repo.all(Sub)
  end

  def list_subs_for_reg(%Reg{} = reg) do
    list_subs_for_reg(reg.id)
  end

  def list_subs_for_reg(reg_id) do
    Repo.all from sub in Sub,
      inner_join: team in assoc(sub, :team),
      inner_join: tregs in assoc(team, :regs),
      where: tregs.id == ^reg_id,
      order_by: [desc: sub.inserted_at]
  end

  def active_sub_for_reg(asg_id, %Reg{} = reg) do
    active_sub_for_reg(asg_id, reg.id)
  end

  def active_sub_for_reg(asg_id, reg_id) do
    Repo.one from sub in Sub,
      where: sub.reg_id == ^reg_id,
      where: sub.assignment_id == ^asg_id,
      where: sub.active,
      limit: 1
  end

  def active_sub_for_team(asg_id, team_id) do
    Repo.one from sub in Sub,
      where: sub.team_id == ^team_id,
      where: sub.assignment_id == ^asg_id,
      where: sub.active,
      limit: 1
  end

  @doc """
  Gets a single sub.

  Raises `Ecto.NoResultsError` if the Sub does not exist.

  ## Examples

      iex> get_sub!(123)
      %Sub{}

      iex> get_sub!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sub!(id) do
    Repo.one! from sub in Sub,
      where: sub.id == ^id,
      inner_join: upload in assoc(sub, :upload),
      inner_join: reg in assoc(sub, :reg),
      inner_join: user in assoc(reg, :user),
      inner_join: team in assoc(sub, :team),
      left_join: grades in assoc(sub, :grades),
      left_join: lcs in assoc(grades, :line_comments),
      left_join: gc in assoc(grades, :grade_column),
      preload: [upload: upload, team: team,
                grades: {grades, grade_column: gc, line_comments: lcs},
                reg: {reg, user: user}]
  end

  def get_sub_path!(id) do
    Repo.one! from sub in Sub,
      where: sub.id == ^id,
      inner_join: team in assoc(sub, :team),
      left_join: team_regs in assoc(team, :regs),
      left_join: grades in assoc(sub, :grades),
      inner_join: as in assoc(sub, :assignment),
      left_join: grade_columns in assoc(as, :grade_columns),
      inner_join: bucket in assoc(as, :bucket),
      inner_join: course in assoc(bucket, :course),
      preload: [assignment: {as, bucket: {bucket, course: course},
                             grade_columns: grade_columns},
               team: {team, regs: team_regs}]
  end

  @doc """
  Creates a sub.

  ## Examples

      iex> create_sub(%{field: value})
      {:ok, %Sub{}}

      iex> create_sub(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sub(attrs \\ %{}) do
    result = %Sub{}
    |> Sub.changeset(attrs)
    |> Repo.insert()

    case result do
      {:ok, sub} ->
        set_one_sub_active!(sub)
        autograde!(sub)
        {:ok, sub}
      error ->
        error
    end
  end

  def autograde!(sub) do
    asg = Inkfish.Assignments.get_assignment!(sub.assignment_id)

    Enum.each asg.grade_columns, fn gcol ->
      if gcol.kind == "script" do
        {:ok, _grade} = Grades.create_autograde(sub.id, gcol.id)
      end
    end
  end

  def set_one_sub_active!(new_sub) do
    prev = active_sub_for_team(new_sub.assignment_id, new_sub.team_id)
    # If the active sub has been graded or late penalty ignored, we keep it.
    if prev && (prev.score || prev.ignore_late_penalty)  do
      set_sub_active!(prev)
    else
      set_sub_active!(new_sub)
    end
  end

  def set_sub_active!(new_sub) do
    asg_id = new_sub.assignment_id
    team_id = new_sub.team_id
    team = Teams.get_team!(team_id)

    # This should be the active sub for each member of the
    # team.

    member_ids = Enum.map team.team_members, &(&1.reg_id)

    teams = Repo.all from tt in Team,
      left_join: members in assoc(tt, :team_members),
      where: members.reg_id in ^member_ids

    team_ids = Enum.map teams, &(&1.id)

    subs = from sub in Sub,
      where: sub.assignment_id == ^asg_id,
      where: sub.team_id in ^team_ids

    {:ok, _} = Ecto.Multi.new
    |> Ecto.Multi.update_all(:subs, subs, set: [active: false])
    |> Ecto.Multi.update(:sub, Sub.make_active(new_sub))
    |> Repo.transaction()
  end

  @doc """
  Updates a sub.

  ## Examples

      iex> update_sub(sub, %{field: new_value})
      {:ok, %Sub{}}

      iex> update_sub(sub, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sub(%Sub{} = sub, attrs) do
    sub
    |> Sub.changeset(attrs)
    |> Repo.update()
  end

  def update_sub_ignore_late(%Sub{} = sub, attrs) do
    {:ok, sub} = sub
    |> Sub.change_ignore_late(attrs)
    |> Repo.update()
    if sub.ignore_late_penalty do
      set_sub_active!(sub)
    end
    calc_sub_score!(sub.id)
    sub
  end

  def calc_sub_score!(sub_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:sub0, fn (_,_) ->
      sub = Repo.one from sub in Sub,
        inner_join: as in assoc(sub, :assignment),
        left_join: grade_columns in assoc(as, :grade_columns),
        left_join: grades in assoc(sub, :grades),
        preload: [assignment: {as, grade_columns: grade_columns}, grades: grades],
        where: sub.id == ^sub_id
      {:ok, sub}
    end)
    |> Ecto.Multi.update(:sub, fn %{sub0: sub} ->
      scores = Enum.map sub.assignment.grade_columns, fn gdr ->
        grade = Enum.find sub.grades, &(&1.grade_column_id == gdr.id)
        grade && grade.score
      end
      if Enum.all? scores, &(!is_nil(&1)) do
        late_penalty = late_penalty(sub)
        total = Enum.reduce(scores, Decimal.new("0"), &Decimal.add/2)
        |> apply_penalty(late_penalty)
        Ecto.Changeset.change(sub, score: total, late_penalty: late_penalty)
      else
        Ecto.Changeset.change(sub, score: nil)
      end
    end)
    |> Repo.transaction()
  end

  def hours_late(sub) do
    due = LocalTime.from_naive!(sub.assignment.due)
    subed = LocalTime.from_naive!(sub.inserted_at)
    seconds_late = DateTime.diff(subed, due)
    hours_late = floor((seconds_late + 3599) / 3600)
    if hours_late > 0 do
      hours_late
    else
      0
    end
  end

  def apply_penalty(score0, penalty) do
    score1 = Decimal.sub(score0, penalty)
    if Decimal.cmp(score1, Decimal.new("0")) == :lt do
      0
    else
      score1
    end
  end

  def late_penalty(sub) do
    points_avail = Inkfish.Assignments.Assignment.assignment_total_points(sub.assignment)
    penalty_frac = Decimal.from_float(hours_late(sub) / 100.0)
    penalty = Decimal.mult(points_avail, penalty_frac)
    if sub.ignore_late_penalty do
      0
    else
      penalty
    end
  end


  @doc """
  Deletes a Sub.

  ## Examples

      iex> delete_sub(sub)
      {:ok, %Sub{}}

      iex> delete_sub(sub)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sub(%Sub{} = _sub) do
    #Repo.delete(sub)
    {:error, "We don't delete subs"}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sub changes.

  ## Examples

      iex> change_sub(sub)
      %Ecto.Changeset{source: %Sub{}}

  """
  def change_sub(%Sub{} = sub) do
    Sub.changeset(sub, %{})
  end

  def read_sub_data(%Sub{} = sub) do
    files = Inkfish.Uploads.Data.read_data(sub.upload)
    %{
      sub_id: sub.id,
      files: files,
    }
  end

  def read_sub_data(sub_id) do
    read_sub_data(get_sub!(sub_id))
  end

  def save_sub_dump!(sub_id) do
    sub = Inkfish.Subs.get_sub!(sub_id)
    json = Sub.to_map(sub)
    |> Jason.encode!(pretty: true)
    Inkfish.Subs.save_sub_dump!(sub.id, json)
  end

  def save_sub_dump!(sub_id, json) do
    sub = get_sub!(sub_id)
    base = Inkfish.Uploads.Upload.upload_dir(sub.upload_id)
    path = Path.join(base, "dump.json")
    File.write!(path, json)
    #IO.inspect({"Data for sub dumped", sub.id, path})
  end
end
