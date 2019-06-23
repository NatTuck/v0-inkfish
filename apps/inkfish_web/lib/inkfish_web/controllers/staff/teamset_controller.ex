defmodule InkfishWeb.Staff.TeamsetController do
  use InkfishWeb, :controller

  plug InkfishWeb.Plugs.FetchItem, [teamset: :teamset]
    when action not in [:index, :new, :create]
  plug InkfishWeb.Plugs.FetchCourse

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {"Team Sets", :staff_course_teamset, :index, :course}
  plug Breadcrumb, {:show, :staff, :teamset}
    when action in [:edit]

  alias Inkfish.Teams
  alias Inkfish.Teams.Teamset

  def index(conn, _params) do
    teamsets = Teams.list_teamsets()
    render(conn, "index.html", teamsets: teamsets)
  end

  def new(conn, _params) do
    changeset = Teams.change_teamset(%Teamset{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"teamset" => teamset_params}) do
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
    render(conn, "show.html", teamset: teamset)
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
    |> redirect(to: Routes.staff_teamset_path(conn, :index))
  end
end
