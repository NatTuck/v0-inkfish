defmodule InkfishWeb.Plugs.RequireReg do
  use InkfishWeb, :controller

  alias Inkfish.Users

  def init(args), do: args

  def call(conn, args \\ []) do
    user = conn.assigns[:current_user]
    course = conn.assigns[:course]
    reg = Users.find_reg(user, course)

    is_staff = reg && (reg.is_staff || reg.is_prof)

    if is_nil(reg) || (args[:staff] && !is_staff && !user.is_admin) do
      if conn.assigns[:client_mode] == :browser do
        conn
        |> put_flash(:error, "Access denied.")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt
      else
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, ~s({error: "Access denied."}))
        |> halt
      end
    else
      conn
      |> assign(:current_reg, reg)
    end
  end
end
