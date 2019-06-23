defmodule InkfishWeb.Staff.TeamsetControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Teams

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:teamset) do
    {:ok, teamset} = Teams.create_teamset(@create_attrs)
    teamset
  end

  describe "index" do
    test "lists all teamsets", %{conn: conn} do
      conn = get(conn, Routes.staff_teamset_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Teamsets"
    end
  end

  describe "new teamset" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.staff_teamset_path(conn, :new))
      assert html_response(conn, 200) =~ "New Teamset"
    end
  end

  describe "create teamset" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.staff_teamset_path(conn, :create), teamset: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_teamset_path(conn, :show, id)

      conn = get(conn, Routes.staff_teamset_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Teamset"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.staff_teamset_path(conn, :create), teamset: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Teamset"
    end
  end

  describe "edit teamset" do
    setup [:create_teamset]

    test "renders form for editing chosen teamset", %{conn: conn, teamset: teamset} do
      conn = get(conn, Routes.staff_teamset_path(conn, :edit, teamset))
      assert html_response(conn, 200) =~ "Edit Teamset"
    end
  end

  describe "update teamset" do
    setup [:create_teamset]

    test "redirects when data is valid", %{conn: conn, teamset: teamset} do
      conn = put(conn, Routes.staff_teamset_path(conn, :update, teamset), teamset: @update_attrs)
      assert redirected_to(conn) == Routes.staff_teamset_path(conn, :show, teamset)

      conn = get(conn, Routes.staff_teamset_path(conn, :show, teamset))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, teamset: teamset} do
      conn = put(conn, Routes.staff_teamset_path(conn, :update, teamset), teamset: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Teamset"
    end
  end

  describe "delete teamset" do
    setup [:create_teamset]

    test "deletes chosen teamset", %{conn: conn, teamset: teamset} do
      conn = delete(conn, Routes.staff_teamset_path(conn, :delete, teamset))
      assert redirected_to(conn) == Routes.staff_teamset_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_teamset_path(conn, :show, teamset))
      end
    end
  end

  defp create_teamset(_) do
    teamset = fixture(:teamset)
    {:ok, teamset: teamset}
  end
end
