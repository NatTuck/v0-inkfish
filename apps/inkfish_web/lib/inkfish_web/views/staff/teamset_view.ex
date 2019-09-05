defmodule InkfishWeb.Staff.TeamsetView do
  use InkfishWeb, :view

  def render("teamset.json", %{teamset: teamset}) do
    course = get_assoc(teamset, :course)
    assigns = get_assoc(teamset, :assignments) || []
    teams = get_assoc(teamset, :teams) || []

    %{
      id: teamset.id,
      name: teamset.name,
      course: render_one(course, InkfishWeb.Staff.CourseView, "course.json"),
      assignments: render_many(assigns, Inkfish.Staff.AssignmentView, "assignment.json"),
      teams: render_many(teams, InkfishWeb.Staff.TeamView, "team.json"),
    }
  end
end
