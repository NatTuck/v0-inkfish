defmodule Inkfish.Subs do
  @moduledoc """
  The Subs context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Subs.Sub
  alias Inkfish.Users.Reg

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
      where: sub.reg_id == ^reg_id,
      order_by: [desc: :inserted_at]
  end

  def active_sub_for_reg(%Reg{} = reg) do
    active_sub_for_reg(reg.id)
  end

  def active_sub_for_reg(reg_id) do
    Repo.one from sub in Sub,
      where: sub.reg_id == ^reg_id and sub.active
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
      left_join: grades in assoc(sub, :grades),
      preload: [upload: upload, grades: grades]
  end

  def get_sub_path!(id) do
    sub = Repo.one! from sub in Sub,
      where: sub.id == ^id,
      left_join: grades in assoc(sub, :grades),
      inner_join: as in assoc(sub, :assignment),
      left_join: graders in assoc(as, :graders),
      inner_join: bucket in assoc(as, :bucket),
      inner_join: course in assoc(bucket, :course),
      preload: [assignment: {as, bucket: {bucket, course: course}, graders: graders}]
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
        set_one_sub_active(sub)
        {:ok, sub}
      error ->
        error
    end
  end

  def set_one_sub_active(new_sub) do
    reg_id = new_sub.reg_id
    asg_id = new_sub.assignment_id
    prev = active_sub_for_reg(reg_id)
    # If the active sub has been graded, we keep it.
    unless prev && prev.score do
      user_subs = from sub in Sub,
        where: sub.reg_id == ^reg_id and sub.assignment_id == ^asg_id

      Ecto.Multi.new
      |> Ecto.Multi.update_all(:subs, user_subs, set: [active: false])
      |> Ecto.Multi.update(:sub, Sub.make_active(new_sub))
      |> Repo.transaction()
    end
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

  def calc_sub_score!(sub_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:sub0, fn (_,_) ->
      sub = Repo.one from sub in Sub,
        lock: "FOR UPDATE",
        inner_join: as in assoc(sub, :assignment),
        left_join: graders in assoc(as, :graders),
        left_join: grades in assoc(sub, :grades),
        preload: [assignment: {as, graders: graders}, grades: grades]
      {:ok, sub}
    end)
    |> Ecto.Multi.update(:sub, fn %{sub0: sub} ->
      scores = Enum.map sub.assignment.graders, fn gdr ->
        grade = Enum.find sub.grades, &(&1.grader_id == gdr.id)
        grade && grade.score
      end
      if Enum.all? scores, &(!is_nil(&1)) do
        total = Enum.reduce scores, Decimal.new("0"), &Decimal.add/2
        Ecto.Changeset.change(sub, score: total)
      else
        Ecto.Changeset.change(sub, score: nil)
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes a Sub.

  ## Examples

      iex> delete_sub(sub)
      {:ok, %Sub{}}

      iex> delete_sub(sub)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sub(%Sub{} = sub) do
    Repo.delete(sub)
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
end
