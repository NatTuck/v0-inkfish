defmodule InkfishWeb.Plugs.RequireUser do
  use InkfishWeb, :controller
  
  alias Inkfish.Users.User
  
  def init(args), do: args
  
  def call(conn, args) do
    require_user(conn, conn.assigns[:current_user], args[:admin])
  end
  
  defp require_user(conn, nil, _admin) do
    conn
    |> put_flash(:error, "Please log in.")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt
  end
  
  defp require_user(conn, %User{is_admin: false}, true) do
    conn
    |> put_flash(:error, "Access denied.")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt
  end
  
  defp require_user(conn, %User{}, _admin) do
    conn
  end
end
