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
 
  @doc """
  Authenticate a user by email and password.

  Returns the User on success, or nil on failure.
  """
  def get_and_auth_user(email, pass) do
    user = Repo.get_by(User, email: email)
    case Argon2.check_pass(user, pass) do
      {:ok, user} => user
      _else       => nil
    end
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
