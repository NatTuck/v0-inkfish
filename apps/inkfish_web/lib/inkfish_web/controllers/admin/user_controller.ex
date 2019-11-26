defmodule InkfishWeb.Admin.UserController do
  use InkfishWeb, :controller

  alias Inkfish.Users

  plug InkfishWeb.Plugs.RequireUser, admin: true

  plug InkfishWeb.Plugs.Breadcrumb, {"Admin Users", :admin_user, :index}
    
  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.admin_user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    case Users.delete_user(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: Routes.admin_user_path(conn, :index))
      {:error, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: Routes.admin_user_path(conn, :index))
    end
  end

  def impersonate(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    conn
    |> put_flash(:info, "Impersonating #{user.login}")
    |> put_session(:real_uid, conn.assigns[:current_user].id)
    |> put_session(:user_id, user.id)
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
