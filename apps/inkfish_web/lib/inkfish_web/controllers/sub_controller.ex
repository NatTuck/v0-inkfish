defmodule InkfishWeb.SubController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [sub: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.FetchItem, [assignment: "assignment_id"]
    when action in [:index, :new, :create]
  plug Plugs.RequireReg
  plug Plugs.RequireSubmitter
    when action in [:show]

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {:show, :course}
  plug Breadcrumb, {:show, :assignment}

  alias Inkfish.Subs
  alias Inkfish.Subs.Sub
  alias Inkfish.Teams

  def new(conn, _params) do
    asg = conn.assigns[:assignment]
    reg = conn.assigns[:current_reg]
    team = Teams.get_active_team(asg, reg)

    if team do
      changeset = Subs.change_sub(%Sub{})
      render(conn, "new.html", changeset: changeset, team: team)
    else
      conn
      |> put_flash(:error, "You need a team to submit.")
      |> redirect(to: Routes.assignment_path(conn, :show, asg))
    end
  end

  def create(conn, %{"sub" => sub_params}) do
    asg = conn.assigns[:assignment]
    reg = conn.assigns[:current_reg]
    team = Teams.get_active_team(asg, reg)
   
    sub_params = sub_params
    |> Map.put("assignment_id", asg.id)
    |> Map.put("reg_id", reg.id)
    |> Map.put("team_id", team.id)

    case Subs.create_sub(sub_params) do
      {:ok, sub} ->
        conn
        |> put_flash(:info, "Sub created successfully.")
        |> redirect(to: Routes.sub_path(conn, :show, sub))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sub = Subs.get_sub!(id)
    sub = %{sub | team: Teams.get_team!(sub.team_id)}
    render(conn, "show.html", sub: sub)
  end
end
