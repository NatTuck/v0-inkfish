defmodule Inkfish.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Courses.Course
  alias Inkfish.Teams.Teamset
  alias Inkfish.Teams.Team
  alias Inkfish.Teams.TeamMember
  alias Inkfish.Assignments.Assignment
  alias Inkfish.Users.Reg

  @doc """
  Returns the list of teamsets.

  ## Examples

      iex> list_teamsets()
      [%Teamset{}, ...]

  """
  def list_teamsets do
    Repo.all(Teamset)
  end

  def list_teamsets(%Course{} = course) do
    list_teamsets(course.id)
  end

  def list_teamsets(course_id) do
    Repo.all from ts in Teamset,
      where: ts.course_id == ^course_id,
      order_by: ts.inserted_at
  end

  @doc """
  Gets a single teamset.

  Raises `Ecto.NoResultsError` if the Teamset does not exist.

  ## Examples

      iex> get_teamset!(123)
      %Teamset{}

      iex> get_teamset!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teamset!(id) do
    %Teamset{} = get_teamset(id)
  end

  def get_teamset(id) do
    Repo.one from ts in Teamset,
      where: ts.id == ^id,
      inner_join: course in assoc(ts, :course),
      left_join: cregs in assoc(course, :regs),
      left_join: cuser in assoc(cregs, :user),
      left_join: teams in assoc(ts, :teams),
      left_join: regs in assoc(teams, :regs),
      left_join: user in assoc(regs, :user),
      left_join: subs in assoc(teams, :subs),
      preload: [course: {course, regs: {cregs, user: cuser}},
                teams: {teams, subs: subs, regs: {regs, user: user}}]
  end

  def get_teamset_path!(id) do
    Repo.one! from ts in Teamset,
      where: ts.id == ^id,
      inner_join: course in assoc(ts, :course),
      preload: [course: course]
  end

  def get_solo_teamset!(%Course{} = course) do
    get_teamset!(course.solo_teamset_id)
  end

  @doc """
  Creates a teamset.

  ## Examples

      iex> create_teamset(%{field: value})
      {:ok, %Teamset{}}

      iex> create_teamset(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teamset(attrs \\ %{}) do
    %Teamset{}
    |> Teamset.changeset(attrs)
    |> Repo.insert()
  end

  def create_solo_teamset!(%Course{} = course) do
    attrs = %{ name: "Solo Work", course_id: course.id }
    solo_ts = Teamset.changeset(%Teamset{}, attrs)

    {:ok, items} = Ecto.Multi.new()
    |> Ecto.Multi.insert(:teamset, solo_ts)
    |> Ecto.Multi.update(:course, fn %{teamset: ts} ->
      Course.changeset(course, %{solo_teamset_id: ts.id})
    end)
    |> Repo.transaction()

    items[:teamset]
  end

  @doc """
  Updates a teamset.

  ## Examples

      iex> update_teamset(teamset, %{field: new_value})
      {:ok, %Teamset{}}

      iex> update_teamset(teamset, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teamset(%Teamset{} = teamset, attrs) do
    teamset
    |> Teamset.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Teamset.

  ## Examples

      iex> delete_teamset(teamset)
      {:ok, %Teamset{}}

      iex> delete_teamset(teamset)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teamset(%Teamset{} = teamset) do
    Repo.delete(teamset)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teamset changes.

  ## Examples

      iex> change_teamset(teamset)
      %Ecto.Changeset{source: %Teamset{}}

  """
  def change_teamset(%Teamset{} = teamset) do
    Teamset.changeset(teamset, %{})
  end

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams(teamset_id) do
    Repo.all from team in Team,
      where: team.teamset_id == ^teamset_id,
      left_join: members in assoc(team, :team_members),
      left_join: regs in assoc(team, :regs),
      preload: [team_members: members, regs: regs]
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id) do
    Repo.one! from team in Team,
      where: team.id == ^id,
      inner_join: ts in assoc(team, :teamset),
      left_join: members in assoc(team, :team_members),
      left_join: reg in assoc(members, :reg),
      left_join: user in assoc(reg, :user),
      preload: [team_members: {members, reg: {reg, user: user}},
                teamset: ts, regs: {reg, user: user}]
  end

  def get_team(id) do
    try do
      get_team!(id)
    rescue
      Ecto.NoResultsError -> nil
    end
  end

  def get_team_path!(id) do
    Repo.one! from team in Team,
      where: team.id == ^id,
      inner_join: ts in assoc(team, :teamset),
      inner_join: course in assoc(ts, :course),
      preload: [teamset: {ts, course: course}]
  end

  def get_active_team(%Assignment{} = asg, %Reg{} = reg) do
    asg = Repo.preload(asg, :teamset)
    get_active_team(asg.teamset, reg)
  end

  def get_active_team(%Teamset{} = ts, %Reg{} = reg) do
    team = Repo.one from team in Team,
      inner_join: ts in assoc(team, :teamset),
      left_join: member in assoc(team, :team_members),
      where: team.teamset_id == ^ts.id,
      where: member.reg_id == ^reg.id,
      where: team.active

    team1 = if team == nil && ts.name == "Solo Work" do
      create_solo_team(ts, reg)
    else
      team
    end

    if team1 do
      get_team!(team1.id)
    else
      nil
    end
  end

  def create_solo_team(%Teamset{} = ts, %Reg{} = reg) do
    regs = [Inkfish.Users.Reg.changeset(reg, %{})]
    team_attrs = %{
      active: true,
      teamset_id: ts.id,
      regs: regs
    }
    {:ok, team} = create_team(team_attrs)
    team
  end

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{source: %Team{}}

  """
  def change_team(%Team{} = team) do
    Team.changeset(team, %{})
  end

  @doc """
  Returns the list of team_members.

  ## Examples

      iex> list_team_members()
      [%TeamMember{}, ...]

  """
  def list_team_members do
    Repo.all(TeamMember)
  end

  @doc """
  Gets a single team_member.

  Raises `Ecto.NoResultsError` if the Team member does not exist.

  ## Examples

      iex> get_team_member!(123)
      %TeamMember{}

      iex> get_team_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_member!(id), do: Repo.get!(TeamMember, id)

  @doc """
  Creates a team_member.

  ## Examples

      iex> create_team_member(%{field: value})
      {:ok, %TeamMember{}}

      iex> create_team_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team_member(attrs \\ %{}) do
    %TeamMember{}
    |> TeamMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team_member.

  ## Examples

      iex> update_team_member(team_member, %{field: new_value})
      {:ok, %TeamMember{}}

      iex> update_team_member(team_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team_member(%TeamMember{} = team_member, attrs) do
    team_member
    |> TeamMember.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeamMember.

  ## Examples

      iex> delete_team_member(team_member)
      {:ok, %TeamMember{}}

      iex> delete_team_member(team_member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team_member(%TeamMember{} = team_member) do
    Repo.delete(team_member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team_member changes.

  ## Examples

      iex> change_team_member(team_member)
      %Ecto.Changeset{source: %TeamMember{}}

  """
  def change_team_member(%TeamMember{} = team_member) do
    TeamMember.changeset(team_member, %{})
  end
end
