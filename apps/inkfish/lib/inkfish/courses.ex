defmodule Inkfish.Courses do
  @moduledoc """
  The Courses context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Courses.Course
  alias Inkfish.Courses.Bucket
  alias Inkfish.Users
  alias Inkfish.Users.User
  alias Inkfish.Users.Reg

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id), do: Repo.get!(Course, id)
  def get_course(id), do: Repo.get(Course, id)

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs \\ %{}) do
    course = Course.changeset(%Course{}, attrs)
    instructor = Course.instructor_login(course)

    {:ok, %{course: course}} = Ecto.Multi.new()
    |> Ecto.Multi.insert(:course, course)
    |> course_add_instructor(instructor)
    |> Repo.transaction()

    {:ok, course}
  end

  def course_add_instructor(tx, nil), do: tx

  def course_add_instructor(tx, instructor) do
    user = Users.get_user_by_login!(instructor)

    op = fn %{course: course} ->
      Reg.changeset(%Reg{}, %{user_id: user.id, course_id: course.id, is_prof: true})
    end

    Ecto.Multi.insert(tx, :reg, op, on_conflict: :replace_all,
      conflict_target: [:user_id, :course_id])
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Course{} = course, attrs) do
    course = Course.changeset(course, attrs)
    instructor = Course.instructor_login(course)

    {:ok, %{course: course}} = Ecto.Multi.new()
    |> Ecto.Multi.update(:course, course)
    |> course_add_instructor(instructor)
    |> Repo.transaction()

    {:ok, course}
  end

  @doc """
  Deletes a Course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{source: %Course{}}

  """
  def change_course(%Course{} = course) do
    Course.changeset(course, %{})
  end

  
  def get_one_course_prof(%Course{} = course) do
    Repo.one from uu in User,
      join: rr in Reg, on: rr.user_id == uu.id,
      where: rr.course_id == ^course.id and rr.is_prof,
      limit: 1
  end

  @doc """
  Returns the list of buckets.

  ## Examples

      iex> list_buckets()
      [%Bucket{}, ...]

  """
  def list_buckets do
    Repo.all(Bucket)
  end

  @doc """
  Gets a single bucket.

  Raises `Ecto.NoResultsError` if the Bucket does not exist.

  ## Examples

      iex> get_bucket!(123)
      %Bucket{}

      iex> get_bucket!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bucket!(id), do: Repo.get!(Bucket, id)
  def get_bucket(id), do: Repo.get(Bucket, id)

  @doc """
  Creates a bucket.

  ## Examples

      iex> create_bucket(%{field: value})
      {:ok, %Bucket{}}

      iex> create_bucket(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bucket(attrs \\ %{}) do
    %Bucket{}
    |> Bucket.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bucket.

  ## Examples

      iex> update_bucket(bucket, %{field: new_value})
      {:ok, %Bucket{}}

      iex> update_bucket(bucket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bucket(%Bucket{} = bucket, attrs) do
    bucket
    |> Bucket.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Bucket.

  ## Examples

      iex> delete_bucket(bucket)
      {:ok, %Bucket{}}

      iex> delete_bucket(bucket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bucket(%Bucket{} = bucket) do
    Repo.delete(bucket)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bucket changes.

  ## Examples

      iex> change_bucket(bucket)
      %Ecto.Changeset{source: %Bucket{}}

  """
  def change_bucket(%Bucket{} = bucket) do
    Bucket.changeset(bucket, %{})
  end
end
