defmodule InkfishWeb.Staff.TeamsetController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [teamset: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.FetchItem, [course: "course_id"]
    when action in [:index, :new, :create]
  plug Plugs.RequireReg, staff: true

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {"Team Sets", :staff_course_teamset, :index, :course}
    when action not in [:index]

  alias Inkfish.Teams
  alias Inkfish.Teams.Teamset

  def index(conn, %{"course_id" => course_id}) do
    teamsets = Teams.list_teamsets(course_id)
    render(conn, "index.html", teamsets: teamsets)
  end

  def new(conn, _params) do
    changeset = Teams.change_teamset(%Teamset{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"course_id" => course_id, "teamset" => teamset_params}) do
    teamset_params = teamset_params
    |> Map.put("course_id", course_id)

    case Teams.create_teamset(teamset_params) do
      {:ok, teamset} ->
        conn
        |> put_flash(:info, "Teamset created successfully.")
        |> redirect(to: Routes.staff_teamset_path(conn, :show, teamset))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teamset = Teams.get_teamset!(id)
    data = InkfishWeb.Staff.TeamsetView.render("teamset.json", %{teamset: teamset})
    render(conn, "show.html", teamset: teamset, data: data)
  end

  def edit(conn, %{"id" => id}) do
    teamset = Teams.get_teamset!(id)
    changeset = Teams.change_teamset(teamset)
    render(conn, "edit.html", teamset: teamset, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teamset" => teamset_params}) do
    teamset = Teams.get_teamset!(id)

    case Teams.update_teamset(teamset, teamset_params) do
      {:ok, teamset} ->
        conn
        |> put_flash(:info, "Teamset updated successfully.")
        |> redirect(to: Routes.staff_teamset_path(conn, :show, teamset))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", teamset: teamset, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teamset = Teams.get_teamset!(id)
    {:ok, _teamset} = Teams.delete_teamset(teamset)

    conn
    |> put_flash(:info, "Teamset deleted successfully.")
    |> redirect(to: Routes.staff_course_teamset_path(conn, :index, teamset.course_id))
  end
end
