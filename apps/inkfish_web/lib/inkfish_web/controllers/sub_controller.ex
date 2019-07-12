defmodule InkfishWeb.SubController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [sub: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.FetchItem, [assignment: "assignment_id"]
    when action in [:index, :new, :create]
  plug Plugs.RequireReg

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {:show, :course}
  plug Breadcrumb, {:show, :assignment}

  alias Inkfish.Subs
  alias Inkfish.Subs.Sub

  def new(conn, _params) do
    changeset = Subs.change_sub(%Sub{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sub" => sub_params}) do
    sub_params = sub_params
    |> Map.put("assignment_id", conn.assigns[:assignment].id)
    |> Map.put("reg_id", conn.assigns[:current_reg].id)

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
    render(conn, "show.html", sub: sub)
  end
end
