defmodule Inkfish.Grades.GradeColumn do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [autogenerate: {Inkfish.LocalTime, :now, []}]

  schema "grade_columns" do
    field :kind, :string
    field :name, :string
    field :params, :string, default: ""
    field :points, :decimal  # Points available and weight within assignment.
    field :base, :decimal    # Starting points before grading.
    belongs_to :assignment, Inkfish.Assignments.Assignment
    belongs_to :upload, Inkfish.Uploads.Upload, type: :binary_id
    has_many :grades, Inkfish.Grades.Grade

    # Upload is:
    #  - number: nothing
    #  - feedback: rubric
    #  - script: the script

    timestamps()
  end

  @doc false
  def changeset(grade_column, attrs) do
    grade_column
    |> cast(attrs, [:assignment_id, :name, :kind, :points, :base, :params, :upload_id])
    |> validate_required([:assignment_id, :name, :kind, :points, :base])
  end

  def grade_column_types do
    ["number", "feedback", "script"]
  end
end
