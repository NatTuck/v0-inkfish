defmodule InkfishWeb.PageController do
  use InkfishWeb, :controller

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: Routes.page_path(conn, :dashboard))
    else
      render(conn, "index.html")
    end
  end
  
  def dashboard(conn, _params) do
    if user = conn.assigns[:current_user] do
      regs = Inkfish.Users.list_regs_for_user(user)
      render(conn, "dashboard.html", regs: regs)
    else
      redirect(conn, to: Routes.page_path(conn, :index))
    end
  end
end
