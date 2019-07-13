defmodule InkfishWeb.Staff.SubView do
  use InkfishWeb, :view

  alias Inkfish.Grades.Grader
  alias Inkfish.Grades.Grade

  # FIXME: Does any of this make sense?
  def staff_grade_action(conn, %Grader{kind: "number"} = grader, nil) do
    sub = conn.assigns[:sub]
    link "New Grade", to: Routes.staff_sub_grade_path(conn, :new, sub)
  end

  def staff_grade_action(conn, %Grader{kind: "feedback"} = grader, nil) do
    "new grade"
  end

  def staff_grade_action(conn, %Grader{kind: "script"} = grader, nil) do
    "run script"
  end

  def staff_grade_action(conn, %Grader{} = grader, %Grade{} = grade) do
    "edit"
  end
end
