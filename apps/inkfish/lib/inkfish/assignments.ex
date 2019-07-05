defmodule Inkfish.Assignments do
  @moduledoc """
  The Assignments context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Assignments.Assignment

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
      inner_join: teamset in assoc(as, :teamset),
      left_join: graders in assoc(as, :graders),
      left_join: starter in assoc(as, :starter_upload),
      left_join: solution in assoc(as, :solution_upload),
      preload: [teamset: teamset, graders: graders,
                starter_upload: starter, solution_upload: solution]
  end

  def get_assignment_for_student!(id, user) do
     Repo.one! from as in Assignment,
      where: as.id == ^id,
      inner_join: teamset in assoc(as, :teamset),
      left_join: graders in assoc(as, :graders),
      left_join: starter in assoc(as, :starter_upload),
      left_join: subs in assoc(as, :subs),
      left_join: grades in assoc(subs, :grades),
      left_join: reg in assoc(subs, :reg),
      where: reg.user_id == ^user.id or is_nil(reg.user_id),
      preload: [teamset: teamset, graders: graders, subs: {subs, grades: grades},
                starter_upload: starter]
  end

  def get_assignment_path!(id) do
    Repo.one! from as in Assignment,
      where: as.id == ^id,
      inner_join: bucket in assoc(as, :bucket),
      inner_join: course in assoc(bucket, :course),
      preload: [bucket: {bucket, course: course}]
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
end
