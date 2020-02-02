defmodule Inkfish.LineComments do
  @moduledoc """
  The LineComments context.
  """

  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.LineComments.LineComment
  alias Inkfish.Grades

  @doc """
  Returns the list of line_comments.

  ## Examples

      iex> list_line_comments()
      [%LineComment{}, ...]

  """
  def list_line_comments do
    Repo.all from lc in LineComment,
      preload: [:user]
  end

  def list_line_comments(grade_id) do
    Repo.all from lc in LineComment,
      where: lc.grade_id == ^grade_id,
      preload: [:user]
  end


  @doc """
  Gets a single line_comment.

  Raises `Ecto.NoResultsError` if the Line comment does not exist.

  ## Examples

      iex> get_line_comment!(123)
      %LineComment{}

      iex> get_line_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_line_comment!(id) do
    Repo.one! from lc in LineComment,
      where: lc.id == ^id,
      preload: [:user]
  end

  def get_line_comment_path!(id) do
    Repo.one! from lc in LineComment,
      where: lc.id == ^id,
      inner_join: grade in assoc(lc, :grade),
      inner_join: sub in assoc(grade, :sub),
      inner_join: as in assoc(sub, :assignment),
      inner_join: bucket in assoc(as, :bucket),
      inner_join: course in assoc(bucket, :course),
      preload: [grade: {grade, sub: {sub, assignment:
                {as, bucket: {bucket, course: course}}}}]
  end


  @doc """
  Creates a line_comment.

  ## Examples

      iex> create_line_comment(%{field: value})
      {:ok, %LineComment{}}

      iex> create_line_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_line_comment(attrs \\ %{}) do
    lc = %LineComment{}
    |> LineComment.changeset(attrs)
    |> Repo.insert()

    case lc do
      {:ok, lc} ->
        lc = Repo.preload(lc, :user)
        grade = Grades.get_grade!(lc.grade_id)
        {:ok, %{lc | grade: grade}}
      error ->
        error
    end
  end

  @doc """
  Updates a line_comment.

  ## Examples

      iex> update_line_comment(line_comment, %{field: new_value})
      {:ok, %LineComment{}}

      iex> update_line_comment(line_comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_line_comment(%LineComment{} = line_comment, attrs) do
    result = line_comment
    |> LineComment.changeset(attrs)
    |> Repo.update()

    case result do
      {:ok, %LineComment{} = lc} ->
        {:ok, grade} = Inkfish.Grades.update_feedback_score(lc.grade_id)
        grade = Grades.get_grade!(grade.id)
        Inkfish.Subs.save_sub_dump!(grade.sub.id)
        {:ok, %{lc | grade: grade}}
      other ->
        other
    end
  end

  @doc """
  Deletes a LineComment.

  ## Examples

      iex> delete_line_comment(line_comment)
      {:ok, %LineComment{}}

      iex> delete_line_comment(line_comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_line_comment(%LineComment{} = lc) do
    case Repo.delete(lc) do
      {:ok, lc} ->
        {:ok, grade} = Inkfish.Grades.update_feedback_score(lc.grade_id)
        Inkfish.Subs.save_sub_dump!(grade.sub.id)
        {:ok, %{lc | grade: grade}}
      other ->
        other
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking line_comment changes.

  ## Examples

      iex> change_line_comment(line_comment)
      %Ecto.Changeset{source: %LineComment{}}

  """
  def change_line_comment(%LineComment{} = line_comment) do
    LineComment.changeset(line_comment, %{})
  end
end
