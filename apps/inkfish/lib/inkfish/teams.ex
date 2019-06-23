defmodule Inkfish.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Courses.Course
  alias Inkfish.Teams.Teamset

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
    Repo.all from ts in Teamset,
      where: ts.id == ^course.id
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
  def get_teamset!(id), do: Repo.get!(Teamset, id)
  def get_teamset(id), do: Repo.get(Teamset, id)

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

  alias Inkfish.Teams.Team

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
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
  def get_team!(id), do: Repo.get!(Team, id)
  def get_team(id), do: Repo.get(Team, id)

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
end
