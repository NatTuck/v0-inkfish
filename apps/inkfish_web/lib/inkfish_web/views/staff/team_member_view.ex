defmodule InkfishWeb.Staff.TeamMemberView do
  use InkfishWeb, :view
  alias InkfishWeb.TeamMemberView

  def render("index.json", %{team_members: team_members}) do
    %{data: render_many(team_members, TeamMemberView, "team_member.json")}
  end

  def render("show.json", %{team_member: team_member}) do
    %{data: render_one(team_member, TeamMemberView, "team_member.json")}
  end

  def render("team_member.json", %{team_member: team_member}) do
    %{id: team_member.id}
  end
end
