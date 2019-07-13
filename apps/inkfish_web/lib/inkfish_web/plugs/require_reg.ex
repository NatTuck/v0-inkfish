defmodule InkfishWeb.Plugs.RequireReg do
  use InkfishWeb, :controller

  alias Inkfish.Users

  def init(args), do: args

  def call(conn, args \\ []) do
    user = conn.assigns[:current_user]
    course = conn.assigns[:course]
    reg = Users.find_reg(user, course)

    if is_nil(reg) || (args[:staff] && !reg.is_staff && !user.is_admin) do
      conn
      |> put_flash(:error, "Access denied.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    else
      conn
      |> assign(:current_reg, reg)
    end
  end
end
