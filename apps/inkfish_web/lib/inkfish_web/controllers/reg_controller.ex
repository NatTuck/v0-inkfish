defmodule InkfishWeb.RegController do
  use InkfishWeb, :controller

  alias Inkfish.Users

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [course: "course_id"]
    when action in [:index, :new, :create]
  plug Plugs.FetchItem, [reg: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.RequireReg
  plug :require_self

  def require_self(conn, _args \\ []) do
    user = conn.assigns[:current_user]
    creg = conn.assigns[:current_reg]
    reg  = conn.assigns[:reg]
    is_staff = reg.is_staff || reg.is_prof || user.is_admin

    if is_staff || reg.id == creg.id do
      conn
    else
      conn
      |> put_flash(:error, "Access denied.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end

  def show(conn, %{"id" => id}) do
    reg = Users.get_reg!(id)
    render(conn, "show.html", reg: reg)
  end
end
