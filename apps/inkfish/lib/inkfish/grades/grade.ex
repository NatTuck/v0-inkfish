defmodule Inkfish.Grades.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grades" do
    field :score, :decimal
    belongs_to :sub, Inkfish.Subs.Sub
    belongs_to :grader, Inkfish.Grades.Grader

    timestamps()
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:score])
    |> validate_required([:score])
  end
end
