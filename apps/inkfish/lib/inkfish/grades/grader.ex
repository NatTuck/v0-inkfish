defmodule Inkfish.Grades.Grader do
  use Ecto.Schema
  import Ecto.Changeset

  schema "graders" do
    field :kind, :string
    field :name, :string
    field :params, :string
    field :points, :decimal
    field :weight, :decimal
    belongs_to :assignment, Inkfish.Assignments.Assignment
    belongs_to :upload, Inkfish.Uploads.Upload, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(grader, attrs) do
    grader
    |> cast(attrs, [:assignment_id, :name, :kind, :weight, :points, :params, :upload_id])
    |> validate_required([:assignment_id, :name, :kind, :weight, :points])
  end
end
