defmodule InkfishWeb.Staff.TeamController do
  use InkfishWeb, :controller

  alias Inkfish.Teams
  alias Inkfish.Teams.Team
  alias Inkfish.Users

  action_fallback InkfishWeb.FallbackController

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [team: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.FetchItem, [teamset: "teamset_id"]
    when action in [:index, :new, :create]
  plug Plugs.RequireReg, staff: true

  def index(conn, %{"teamset_id" => teamset_id}) do
    teams = Teams.list_teams(teamset_id)
    render(conn, "index.json", teams: teams)
  end

  def create(conn, %{"teamset_id" => teamset_id, "team" => team_params}) do
    regs = Enum.map (team_params["reg_ids"] || []), fn (reg_id) ->
      Users.get_reg!(reg_id)
    end

    team_params = team_params
    |> Map.put("teamset_id", teamset_id)
    |> Map.put("regs", regs)

    with {:ok, %Team{} = team} <- Teams.create_team(team_params) do
      # Fetch updated teamset
      teamset = Teams.get_teamset!(team.teamset_id)
      team = %{team | teamset: teamset}
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.ajax_staff_team_path(conn, :show, team))
      |> render("show.json", team: team)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Teams.get_team!(id)
    render(conn, "show.json", team: team)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Teams.get_team!(id)

    with {:ok, %Team{} = team} <- Teams.update_team(team, team_params) do
      teamset = Teams.get_teamset!(team.teamset_id)
      team = %{team | teamset: teamset}
      render(conn, "show.json", team: team)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Teams.get_team!(id)

    with {:ok, %Team{}} <- Teams.delete_team(team) do
      teamset = Teams.get_teamset!(team.teamset_id)
      team = %{team | teamset: teamset}
      render(conn, "show.json", team: team)
    end
  end
end
