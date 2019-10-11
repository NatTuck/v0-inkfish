defmodule InkfishWeb.UserController do
  use InkfishWeb, :controller
  
  alias Inkfish.Users

  plug InkfishWeb.Plugs.RequireUser
  plug :user_check_permission

  def user_check_permission(conn, _foo) do
    id = conn.params["id"]
    {id, _} = Integer.parse(id)
    user = conn.assigns[:current_user]
    if !user.is_admin && user.id != id do
      conn
      |> put_flash(:error, "Access denied.")
      |> redirect(to: Routes.page_path(conn, :dashboard))
      |> halt
    else
      conn
    end
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
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end
end
