defmodule InkfishWeb.JoinReqController do
  use InkfishWeb, :controller

  alias Inkfish.JoinReqs
  alias Inkfish.JoinReqs.JoinReq

  plug InkfishWeb.Plugs.FetchItem, [course: "course_id"]
    when action in [:index, :new, :create]
  plug InkfishWeb.Plugs.FetchItem, [join_req: "id"]
    when action not in [:index, :new, :create]

  def new(conn, _params) do
    changeset = JoinReqs.change_join_req(%JoinReq{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"join_req" => params}) do
    params = params
    |> Map.put("user_id", conn.assigns[:current_user].id)
    |> Map.put("course_id", conn.assigns[:course].id)

    case JoinReqs.create_join_req(params) do
      {:ok, join_req} ->
        conn
        |> put_flash(:info, "Join req created successfully.")
        |> redirect(to: Routes.course_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    join_req = JoinReqs.get_join_req!(id)
    render(conn, "show.html", join_req: join_req)
  end
end
