defmodule Inkfish.JoinReqs do
  @moduledoc """
  The JoinReqs context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.JoinReqs.JoinReq
  alias Inkfish.Users.User
  alias Inkfish.Courses.Course

  @doc """
  Returns the list of join_reqs.

  ## Examples

      iex> list_join_reqs()
      [%JoinReq{}, ...]

  """
  def list_join_reqs do
    Repo.all(JoinReq)
  end

  def list_for_course(%Course{} = course) do
    Repo.all from req in JoinReq,
      where: req.course_id == ^course.id,
      inner_join: user in assoc(req, :user),
      preload: [user: user]
  end

  def list_for_user(%User{} = user) do
    Repo.all from jr in JoinReq,
      where: jr.user_id == ^user.id
  end

  @doc """
  Gets a single join_req.

  Raises `Ecto.NoResultsError` if the Join req does not exist.

  ## Examples

      iex> get_join_req!(123)
      %JoinReq{}

      iex> get_join_req!(456)
      ** (Ecto.NoResultsError)

  """
  def get_join_req!(id), do: Repo.get!(JoinReq, id)

  def get_join_req_path!(id) do
    Repo.one! from req in JoinReq,
      where: req.id == ^id,
      inner_join: course in assoc(req, :course),
      inner_join: user in assoc(req, :user),
      preload: [user: user, course: course]
  end

  @doc """
  Creates a join_req.

  ## Examples

      iex> create_join_req(%{field: value})
      {:ok, %JoinReq{}}

      iex> create_join_req(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_join_req(attrs \\ %{}) do
    %JoinReq{}
    |> JoinReq.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a join_req.

  ## Examples

      iex> update_join_req(join_req, %{field: new_value})
      {:ok, %JoinReq{}}

      iex> update_join_req(join_req, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_join_req(%JoinReq{} = join_req, attrs) do
    join_req
    |> JoinReq.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a JoinReq.

  ## Examples

      iex> delete_join_req(join_req)
      {:ok, %JoinReq{}}

      iex> delete_join_req(join_req)
      {:error, %Ecto.Changeset{}}

  """
  def delete_join_req(%JoinReq{} = join_req) do
    Repo.delete(join_req)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking join_req changes.

  ## Examples

      iex> change_join_req(join_req)
      %Ecto.Changeset{source: %JoinReq{}}

  """
  def change_join_req(%JoinReq{} = join_req) do
    JoinReq.changeset(join_req, %{})
  end
end
