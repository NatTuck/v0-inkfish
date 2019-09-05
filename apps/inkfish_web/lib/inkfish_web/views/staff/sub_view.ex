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
    reg = get_assoc(sub, :reg)
    team = get_assoc(sub, :team)

    %{
      active: sub.active,
      assignment_id: sub.assignment_id,
      inserted_at: sub.inserted_at,
      reg_id: sub.reg_id,
      reg: render_one(reg, InkfishWeb.Staff.RegView, "reg.json"),
      team_id: sub.team_id,
      team: render_one(team, InkfishWeb.Staff.TeamView, "team.json"),
    }
  end
end
