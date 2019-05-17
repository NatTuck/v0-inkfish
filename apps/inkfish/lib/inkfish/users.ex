defmodule Inkfish.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)
 
  @doc """
  Gets a single user by id

  Returns nil if User doesn't exist or if given a nil
  user id.
  """
  def get_user(nil), do: nil
  def get_user(id), do: Repo.get(User, id)

  
  def get_user_by_login!(login) do
    Repo.get_by!(User, login: login)
  end
  
  @doc """
  Authenticate a user by email and password.

  Returns the User on success, or nil on failure.
  """
  def auth_and_get_user(login, pass) do
    case Paddle.authenticate(login, pass) do
      :ok ->
        {:ok, data} = Paddle.get(filter: [uid: login])
        {:ok, user} = create_or_update_from_ldap_data(login, hd(data))
        user
      {:error, _} ->
        nil
    end
  end
  
  def create_or_update_from_ldap_data(login, data) do
    attrs = %{
      login: login,
      email: hd(data["mail"]),
      given_name: hd(data["givenName"]),
      surname: hd(data["sn"]),
    }
   
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert(
      conflict_target: :login,
      on_conflict: {:replace, [:email, :given_name, :surname]}
    )
  end
  
  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def search_users(query) do
    query = query
    |> String.replace(~r{[%_\\]}, "\\1")
    qq = "%#{query}%"
    Repo.all from uu in User,
      where: ilike(uu.login, ^qq) or ilike(uu.given_name, ^qq) or ilike(uu.surname, ^qq)
  end

  alias Inkfish.Users.Reg

  @doc """
  Returns the list of regs.

  ## Examples

      iex> list_regs()
      [%Reg{}, ...]

  """
  def list_regs do
    Repo.all(Reg)
  end
  
  alias Inkfish.Courses.Course
  
  def list_regs_for_course(%Course{} = course) do
    list_regs_for_course(course.id)
  end
  
  def list_regs_for_course(course_id) do
    Repo.all from reg in Reg, 
      where: reg.course_id == ^course_id,
      preload: [:user]
  end

  @doc """
  Gets a single reg.

  Raises `Ecto.NoResultsError` if the Reg does not exist.

  ## Examples

      iex> get_reg!(123)
      %Reg{}

      iex> get_reg!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reg!(id), do: Repo.get!(Reg, id)
  def get_reg(id), do: Repo.get(Reg, id)

  @doc """
  Creates a reg.

  ## Examples

      iex> create_reg(%{field: value})
      {:ok, %Reg{}}

      iex> create_reg(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reg(attrs \\ %{}) do
    %Reg{}
    |> Reg.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reg.

  ## Examples

      iex> update_reg(reg, %{field: new_value})
      {:ok, %Reg{}}

      iex> update_reg(reg, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reg(%Reg{} = reg, attrs) do
    reg
    |> Reg.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Reg.

  ## Examples

      iex> delete_reg(reg)
      {:ok, %Reg{}}

      iex> delete_reg(reg)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reg(%Reg{} = reg) do
    Repo.delete(reg)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reg changes.

  ## Examples

      iex> change_reg(reg)
      %Ecto.Changeset{source: %Reg{}}

  """
  def change_reg(%Reg{} = reg) do
    Reg.changeset(reg, %{})
  end
end
