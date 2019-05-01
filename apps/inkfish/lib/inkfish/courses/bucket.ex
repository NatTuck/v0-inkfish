defmodule Inkfish.Courses.Bucket do
  use Ecto.Schema
  import Ecto.Changeset


  schema "buckets" do
    field :name, :string
    field :weight, :decimal
    field :course_id, :id

    timestamps()
  end

  @doc false
  def changeset(bucket, attrs) do
    bucket
    |> cast(attrs, [:name, :weight])
    |> validate_required([:name, :weight])
  end
end
