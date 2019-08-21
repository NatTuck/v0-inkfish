defmodule InkfishWeb.Staff.SubView do
  use InkfishWeb, :view

  alias Inkfish.Grades.Grader
  alias Inkfish.Grades.Grade

  # FIXME: Does any of this make sense?
  def staff_grade_action(conn, %Grader{} = _grader, nil) do
    "create"
  end

  def staff_grade_action(conn, %Grader{} = grader, %Grade{} = grade) do
    "edit"
  end
end
