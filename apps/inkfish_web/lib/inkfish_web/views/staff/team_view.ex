defmodule InkfishWeb.Staff.TeamView do
  use InkfishWeb, :view

  alias Inkfish.Teams.Team
  alias InkfishWeb.Staff.TeamView

  def render("index.json", %{teams: teams}) do
    %{data: render_many(teams, TeamView, "team.json")}
  end

  def render("show.json", %{team: team}) do
    %{data: render_one(team, TeamView, "team.json")}
  end

  def render("team.json", %{team: %Team{} = team}) do
    regs = get_assoc(team, :regs) || []
    teamset = get_assoc(team, :teamset)
    subs = get_assoc(team, :subs) || []

    %{
      id: team.id,
      active: team.active,
      regs: render_many(regs, InkfishWeb.Staff.RegView, "reg.json"),
      teamset: render_one(teamset, InkfishWeb.Staff.TeamsetView, "teamset.json"),
      subs: render_many(subs, InkfishWeb.Staff.SubView, "sub.json"),
    }
  end
end
