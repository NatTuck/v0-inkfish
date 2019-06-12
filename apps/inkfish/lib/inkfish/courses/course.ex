defmodule Inkfish.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset


  schema "courses" do
    field :name, :string
    field :start_date, :date
    field :footer, :string, default: ""
    has_many :regs, Inkfish.Users.Reg
    has_many :buckets, Inkfish.Courses.Bucket

    field :instructor, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :start_date, :footer, :instructor])
    |> validate_required([:name, :start_date])
    |> validate_length(:name, min: 3)
  end

  def instructor_login(course) do
    if instructor = get_field(course, :instructor) do
      String.replace(instructor || "", ~r/\s+\(.*\)$/, "")
    else
      nil
    end
  end
end
