defmodule InkfishWeb.Admin.UserControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  def fixture(:user) do
    insert(:user)
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = conn
      |> login("alice")
      |> get(Routes.admin_user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = conn
      |> login("alice")
      |> get(Routes.admin_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = conn
      |> login("alice")
      |> put(Routes.admin_user_path(conn, :update, user), user: %{"nickname" => "Zach"})
      assert redirected_to(conn) == Routes.admin_user_path(conn, :show, user)

      conn = get(conn, Routes.admin_user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Zach"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
      |> login("alice")
      |> put(Routes.admin_user_path(conn, :update, user), user: %{"email" => "bob"})
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = conn
      |> login("alice")
      |> delete(Routes.admin_user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.admin_user_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.admin_user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end
end
