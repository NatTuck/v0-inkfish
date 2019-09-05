defmodule Inkfish.Courses.Bucket do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [autogenerate: {Inkfish.LocalTime, :now, []}]

  schema "buckets" do
    field :name, :string
    field :weight, :decimal
    belongs_to :course, Inkfish.Courses.Course
    has_many :assignments, Inkfish.Assignments.Assignment

    timestamps()
  end

  @doc false
  def changeset(bucket, attrs) do
    bucket
    |> cast(attrs, [:course_id, :name, :weight])
    |> validate_required([:course_id, :name, :weight])
    |> validate_length(:name, min: 3)
    |> validate_change(:weight, fn (_, weight) ->
      if Decimal.cmp(weight, "0.0") == :lt || Decimal.cmp(weight, "100.0")== :gt do
        [weight: "must be between 0.0 and 100.0, inclusive"]
      else
        []
      end
    end)
  end
end
