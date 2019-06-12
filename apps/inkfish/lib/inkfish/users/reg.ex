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
    |> cast(attrs, [:user_id, :course_id, :is_student, :is_prof, :is_staff, :is_grader])
    |> validate_required([:user_id, :course_id])
    |> validate_not_student_and_staff()
    |> unique_constraint(:user_id, name: :regs_course_id_user_id_index)
  end
  
  def validate_not_student_and_staff(cset) do
    sp = get_field(cset, :is_student) && get_field(cset, :is_prof)
    ss = get_field(cset, :is_student) && get_field(cset, :is_staff)
    
    if sp || ss do
      add_error(cset, :is_student, "Students can't be staff")
    else
      cset
    end
  end
end
