defmodule InkfishWeb.Plugs.FetchUser do
  import Plug.Conn
  
  alias Inkfish.Users
  alias Inkfish.Users.User
  
  def init(args), do: args
  
  def call(conn, _args) do
    user_id = get_session(conn, :user_id)
    user = Users.get_user(user_id)
    token = make_token(conn, user)
    
    conn
    |> assign(:current_user_id, user_id)
    |> assign(:current_user, user)
    |> assign(:current_user_token, token)
  end
  
  def make_token(conn, %User{} = user) do
    Phoenix.Token.sign(conn, "user_id", user.id)
  end
  
  def make_token(_conn, nil) do
    ""
  end
end
