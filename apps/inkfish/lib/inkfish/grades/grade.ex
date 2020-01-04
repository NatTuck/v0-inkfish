defmodule Inkfish.Grades.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inkfish.Uploads.Upload

  @timestamps_opts [autogenerate: {Inkfish.LocalTime, :now, []}]

  schema "grades" do
    field :score, :decimal
    field :log_uuid, :string
    belongs_to :sub, Inkfish.Subs.Sub
    belongs_to :grade_column, Inkfish.Grades.GradeColumn
    belongs_to :grader, Inkfish.Users.User
    has_many :line_comments, Inkfish.LineComments.LineComment

    timestamps()
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:grade_column_id, :sub_id, :score, :grader_id, :log_uuid])
    |> validate_required([:grade_column_id, :sub_id])
  end

  def to_map(grade) do
    grade = Map.drop(grade, [:__struct__, :__meta__, :sub, :grade_column, :grader])
    lcs = Enum.map grade.line_comments, fn lc ->
      Inkfish.LineComments.LineComment.to_map(lc)
    end
    %{ grade | line_comments: lcs }
  end

  def log_path(grade) do
    grade.sub.upload
    |> Upload.logs_path()
    |> Path.join("#{grade.log_uuid}.json")
  end

  def get_log(grade) do
    if grade.log_uuid do
      case File.read(log_path(grade)) do
        {:ok, json} -> Jason.decode!(json)
        _else -> nil
      end
    else
      nil
    end
  end
end
