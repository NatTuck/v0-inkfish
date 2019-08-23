defmodule InkfishWeb.Staff.SubView do
  use InkfishWeb, :view

  alias Inkfish.Grades.GradeColumn
  alias Inkfish.Grades.Grade

  # FIXME: Does any of this make sense?
  def staff_grade_action(conn, %GradeColumn{} = _gcol, nil) do
    "create"
  end

  def staff_grade_action(conn, %GradeColumn{} = _gcol, %Grade{} = _grade) do
    "edit"
  end
end
