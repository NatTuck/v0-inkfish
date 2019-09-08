defmodule InkfishWeb.TeamView do
  use InkfishWeb, :view

  alias Inkfish.Teams.Team

  def render("team.json", %{team: %Team{} = team}) do
    regs = get_assoc(team, :regs) || []
    subs = get_assoc(team, :subs) || []

    %{
      id: team.id,
      active: team.active,
      regs: render_many(regs, InkfishWeb.RegView, "reg.json"),
      subs: render_many(subs, InkfishWeb.SubView, "sub.json"),
    }
  end
end
