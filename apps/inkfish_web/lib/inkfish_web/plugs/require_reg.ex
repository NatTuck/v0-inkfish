defmodule InkfishWeb.Plugs.RequireReg do
  use InkfishWeb, :controller

  alias Inkfish.Users

  def init(args), do: args

  def call(conn, args) do
    user = conn.assigns[:current_user]
    course = conn.assigns[:course]
    if reg = Users.find_reg(user, course) do
      conn
      |> assign(:current_reg, reg)
    else
      conn
      |> put_flash(:error, "Access denied.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end
end
