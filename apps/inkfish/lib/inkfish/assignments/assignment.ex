defmodule Inkfish.Assignments.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assignments" do
    field :desc, :string
    field :due, :naive_datetime
    field :name, :string
    field :weight, :decimal
    field :allow_git, :boolean, default: true
    field :allow_upload, :boolean, default: true


    belongs_to :bucket, Inkfish.Courses.Bucket
    belongs_to :teamset, Inkfish.Teams.Teamset
    belongs_to :starter_upload, Inkfish.Uploads.Upload, type: :binary_id
    belongs_to :solution_upload, Inkfish.Uploads.Upload, type: :binary_id

    has_many :graders, Inkfish.Grades.Grader
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
end
