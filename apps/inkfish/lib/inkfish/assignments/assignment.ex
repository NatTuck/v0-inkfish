defmodule Inkfish.Assignments.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [autogenerate: {Inkfish.LocalTime, :now, []}]

  schema "assignments" do
    field :desc, :string
    field :due, :naive_datetime
    field :name, :string
    field :weight, :decimal
    field :points, :decimal
    field :allow_git, :boolean, default: true
    field :allow_upload, :boolean, default: true

    belongs_to :bucket, Inkfish.Courses.Bucket
    belongs_to :teamset, Inkfish.Teams.Teamset
    belongs_to :starter_upload, Inkfish.Uploads.Upload, type: :binary_id
    belongs_to :solution_upload, Inkfish.Uploads.Upload, type: :binary_id

    has_many :grade_columns, Inkfish.Grades.GradeColumn
    has_many :subs, Inkfish.Subs.Sub

    timestamps()
  end

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:name, :desc, :due, :weight, :bucket_id, :teamset_id,
                    :starter_upload_id, :solution_upload_id, :allow_git,
                    :allow_upload])
    |> validate_required([:name, :desc, :due, :weight, :bucket_id, :teamset_id])
  end

  def assignment_total_points(as) do
    Enum.reduce as.grade_columns, Decimal.new("0"), fn (gcol, sum) ->
      Decimal.add(gcol.points, sum)
    end
  end
end
