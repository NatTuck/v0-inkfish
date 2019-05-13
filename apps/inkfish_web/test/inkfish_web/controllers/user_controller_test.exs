defmodule InkfishWeb.UserControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory
  
  alias Inkfish.Users

  def fixture(:user) do
    insert(:user)
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = conn
      |> login("alice")
      |> get(Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  # describe "new user" do
  #   test "renders form", %{conn: conn} do
  #     conn = get(conn, Routes.user_path(conn, :new))
  #     assert html_response(conn, 200) =~ "New User"
  #   end
  # end

  # describe "create user" do
  #   test "redirects to show when data is valid", %{conn: conn} do
  #     attrs = params_for(:user)
  #     conn = post(conn, Routes.user_path(conn, :create), user: attrs)

  #     assert %{id: id} = redirected_params(conn)
  #     assert redirected_to(conn) == Routes.user_path(conn, :show, id)

  #     conn = get(conn, Routes.user_path(conn, :show, id))
  #     assert html_response(conn, 200) =~ "Show User"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     attrs = %{email: "+++"}
  #     conn = post(conn, Routes.user_path(conn, :create), user: attrs)
  #     assert html_response(conn, 200) =~ "New User"
  #   end
  # end

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

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = conn
      |> login("alice")
      |> delete(Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end
end
