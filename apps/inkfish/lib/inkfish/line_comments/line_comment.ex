defmodule Inkfish.LineComments.LineComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "line_comments" do
    field :line, :integer
    field :path, :string
    field :points, :decimal
    field :text, :string
    field :grade_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(line_comment, attrs) do
    line_comment
    |> cast(attrs, [:path, :line, :points, :text, :grade_id, :user_id])
    |> validate_required([:path, :line, :points, :text, :grade_id, :user_id])
  end
end
