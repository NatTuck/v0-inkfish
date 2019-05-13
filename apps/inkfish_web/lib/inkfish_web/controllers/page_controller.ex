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
    if conn.assigns[:current_user] do
      courses = Inkfish.Courses.list_courses() 
      render(conn, "dashboard.html", courses: courses)
    else
      redirect(conn, to: Routes.page_path(conn, :index))
    end
  end
end
