defmodule InkfishWeb.SubView do
  use InkfishWeb, :view

  def render("sub.json", %{sub: sub}) do
    reg = get_assoc(sub, :reg)
    team = get_assoc(sub, :team)
    #grades = get_assoc(sub, :grades) || []

    %{
      active: sub.active,
      assignment_id: sub.assignment_id,
      inserted_at: sub.inserted_at,
      reg_id: sub.reg_id,
      reg: render_one(reg, InkfishWeb.RegView, "reg.json"),
      team_id: sub.team_id,
      team: render_one(team, InkfishWeb.TeamView, "team.json"),
      #grades: render_many(grades, InkfishWeb.GradeView, "grade.json"),
    }
  end
end
