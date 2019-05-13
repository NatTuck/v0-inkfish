defmodule InkfishWeb.Plugs.FetchItem do
  use InkfishWeb, :controller
  
  def init(args), do: args
 
  def call(conn, [{name, target}]) do
    id = case conn.params do
           %{"id" => id} -> id
         end
    
    item = fetch(target, id)
    
    if item do
      conn
      |> assign(:course_id, item[:course_id])
      |> assign(name, item)
    else
      conn
    end
  end
  
  def fetch(:user, id) do
    Inkfish.Users.get_user(id)
  end
  
  def fetch(:reg, id) do
    Inkfish.Users.get_reg(id)
  end
  
  def fetch(:course, id) do
    Inkfish.Courses.get_course(id)
  end
  
  def fetch(:bucket, id) do
    Inkfish.Courses.get_bucket(id)
  end
end
