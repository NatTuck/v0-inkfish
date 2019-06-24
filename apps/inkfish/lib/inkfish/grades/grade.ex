defmodule Inkfish.Grades.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grades" do
    field :score, :decimal
    field :sub_id, :id
    field :grader_id, :id

    timestamps()
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:score])
    |> validate_required([:score])
  end
end
