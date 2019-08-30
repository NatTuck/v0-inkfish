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
      dues = Enum.reduce regs, %{}, fn (reg, acc) ->
        next = Inkfish.Users.next_due(reg)
        Map.put(acc, reg.course_id, next)
      end
      render(conn, "dashboard.html", regs: regs, dues: dues)
    else
      redirect(conn, to: Routes.page_path(conn, :index))
    end
  end
end
