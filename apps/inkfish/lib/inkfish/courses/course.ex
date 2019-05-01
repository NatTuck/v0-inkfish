defmodule Inkfish.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset


  schema "courses" do
    field :footer, :string
    field :name, :string
    field :start_date, :date
    has_many :regs, Inkfish.Users.Reg

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :start_date, :footer])
    |> validate_required([:name, :start_date, :footer])
  end
end
