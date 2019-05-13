defmodule InkfishWeb.Plugs.FetchCourse do
  use InkfishWeb, :controller
  
  alias Inkfish.Courses
  
  def init(args), do: args
  
  def call(conn, _args) do
    id = if conn.assigns[:course] do
      conn.assigns[:course_id]
    else
      conn.params["course_id"]
    end
    course = Courses.get_course(id)
    if course do
      conn
      |> assign(:course, course)
    else
      conn
      |> put_flash(:error, "No such course")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
