defmodule InkfishWeb.Plugs.FetchUser do
  import Plug.Conn
  
  alias Inkfish.Users
  
  def init(args), do: args
  
  def call(conn, args) do
    user_id = get_session(conn, :user_id)
    user = Users.get_user(user_id)
    
    conn
    |> assign(:current_user_id, user_id)
    |> assign(:current_user, user)
  end 
end
