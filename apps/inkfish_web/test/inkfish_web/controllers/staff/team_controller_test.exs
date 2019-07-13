defmodule InkfishWeb.Staff.TeamControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Teams

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:team) do
    {:ok, team} = Teams.create_team(@create_attrs)
    team
  end

  describe "index" do
    test "lists all teams", %{conn: conn} do
      conn = get(conn, Routes.staff_team_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Teams"
    end
  end

  describe "new team" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.staff_team_path(conn, :new))
      assert html_response(conn, 200) =~ "New Team"
    end
  end

  describe "create team" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.staff_team_path(conn, :create), team: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.staff_team_path(conn, :show, id)

      conn = get(conn, Routes.staff_team_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Team"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.staff_team_path(conn, :create), team: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Team"
    end
  end

  describe "edit team" do
    setup [:create_team]

    test "renders form for editing chosen team", %{conn: conn, team: team} do
      conn = get(conn, Routes.staff_team_path(conn, :edit, team))
      assert html_response(conn, 200) =~ "Edit Team"
    end
  end

  describe "update team" do
    setup [:create_team]

    test "redirects when data is valid", %{conn: conn, team: team} do
      conn = put(conn, Routes.staff_team_path(conn, :update, team), team: @update_attrs)
      assert redirected_to(conn) == Routes.staff_team_path(conn, :show, team)

      conn = get(conn, Routes.staff_team_path(conn, :show, team))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, team: team} do
      conn = put(conn, Routes.staff_team_path(conn, :update, team), team: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Team"
    end
  end

  describe "delete team" do
    setup [:create_team]

    test "deletes chosen team", %{conn: conn, team: team} do
      conn = delete(conn, Routes.staff_team_path(conn, :delete, team))
      assert redirected_to(conn) == Routes.staff_team_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.staff_team_path(conn, :show, team))
      end
    end
  end

  defp create_team(_) do
    team = fixture(:team)
    {:ok, team: team}
  end
end