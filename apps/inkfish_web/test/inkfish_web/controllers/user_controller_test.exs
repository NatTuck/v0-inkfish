defmodule InkfishWeb.UserControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory
  
  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = conn
      |> login("alice")
      |> get(Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = conn
      |> login("alice")
      |> put(Routes.user_path(conn, :update, user), user: %{given_name: "Rob"})
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Rob"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
      |> login("alice")
      |> put(Routes.user_path(conn, :update, user), user: %{email: "+++"})
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end
end
