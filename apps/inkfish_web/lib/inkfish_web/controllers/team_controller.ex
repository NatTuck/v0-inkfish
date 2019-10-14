defmodule InkfishWeb.TeamController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [team: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.RequireReg

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {:show, :course}

  alias Inkfish.Teams

  def show(conn, %{"id" => id}) do
    team = Teams.get_team!(id)
    render(conn, "show.html", team: team)
  end
end
