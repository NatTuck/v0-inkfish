defmodule InkfishWeb.SessionController do
  use InkfishWeb, :controller
  
  alias Inkfish.Users
  
  def create(conn, %{"login" => login, "password" => pass }) do
    user = Users.auth_and_get_user(login, pass)
    if user do
      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:info, "Logged in as #{user.email}")
      |> redirect(to: Routes.page_path(conn, :dashboard))
    else
      conn
      |> put_flash(:error, "Login failed.")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end
  
  def delete(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def resume(conn, _params) do
    user = Users.get_user!(get_session(conn, :real_uid))
    conn
    |> delete_session(:real_uid)
    |> put_session(:user_id, user.id)
    |> put_flash(:info, "No longer impersonating anyone.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
