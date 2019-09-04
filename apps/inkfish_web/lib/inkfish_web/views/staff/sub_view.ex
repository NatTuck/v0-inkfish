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

  def render("sub.json", %{sub: sub}) do
    %{
      active: sub.active,
      assignment_id: sub.assignment_id,
      inserted_at: sub.inserted_at,
      reg_id: sub.reg_id,
      team_id: sub.team_id,
    }
  end
end
