defmodule Inkfish.Users.Reg do
  use Ecto.Schema
  import Ecto.Changeset


  schema "regs" do
    field :is_grader, :boolean, default: false
    field :is_prof, :boolean, default: false
    field :is_staff, :boolean, default: false
    field :is_student, :boolean, default: false
    belongs_to :user, Inkfish.Users.User
    belongs_to :course, Inkfish.Courses.Course

    timestamps()
  end

  @doc false
  def changeset(reg, attrs) do
    reg
    |> cast(attrs, [:is_student, :is_prof, :is_staff, :is_grader])
    |> validate_required([:is_student, :is_prof, :is_staff, :is_grader])
  end
end
