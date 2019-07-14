defmodule Inkfish.JoinReqs.JoinReq do
  use Ecto.Schema
  import Ecto.Changeset

  schema "join_reqs" do
    belongs_to :course, Inkfish.Courses.Course
    belongs_to :user, Inkfish.Users.User
    field :note, :string, default: ""
    field :staff_req, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(join_req, attrs) do
    join_req
    |> cast(attrs, [:course_id, :user_id, :note, :staff_req])
    |> validate_required([:course_id, :user_id])
  end
end
