defmodule Inkfish.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inkfish.Users.User

  @timestamps_opts [autogenerate: {Inkfish.LocalTime, :now, []}]

  schema "courses" do
    field :name, :string
    field :start_date, :date
    field :footer, :string, default: ""
    field :grade_hide_days, :integer
    has_many :regs, Inkfish.Users.Reg
    has_many :join_reqs, Inkfish.JoinReqs.JoinReq
    has_many :buckets, Inkfish.Courses.Bucket
    has_many :teamsets, Inkfish.Teams.Teamset
    belongs_to :solo_teamset, Inkfish.Teams.Teamset

    field :instructor, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :start_date, :footer, :instructor, :solo_teamset_id])
    |> validate_required([:name, :start_date])
    |> validate_length(:name, min: 3)
  end

  def instructor_login(course) do
    if instructor = get_field(course, :instructor) do
      User.normalize_login(instructor)
    else
      nil
    end
  end
end
