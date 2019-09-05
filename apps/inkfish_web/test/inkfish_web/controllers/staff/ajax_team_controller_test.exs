defmodule InkfishWeb.Ajax.TeamControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Teams
  alias Inkfish.Teams.Team

  @create_attrs %{
    active: true
  }
  @update_attrs %{
    active: false
  }
  @invalid_attrs %{active: nil}

  def fixture(:team) do
    {:ok, team} = Teams.create_team(@create_attrs)
    team
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all teams", %{conn: conn} do
      conn = get(conn, Routes.ajax_team_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create team" do
    test "renders team when data is valid", %{conn: conn} do
      conn = post(conn, Routes.ajax_team_path(conn, :create), team: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.ajax_team_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.ajax_team_path(conn, :create), team: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update team" do
    setup [:create_team]

    test "renders team when data is valid", %{conn: conn, team: %Team{id: id} = team} do
      conn = put(conn, Routes.ajax_team_path(conn, :update, team), team: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.ajax_team_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, team: team} do
      conn = put(conn, Routes.ajax_team_path(conn, :update, team), team: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete team" do
    setup [:create_team]

    test "deletes chosen team", %{conn: conn, team: team} do
      conn = delete(conn, Routes.ajax_team_path(conn, :delete, team))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.ajax_team_path(conn, :show, team))
      end
    end
  end

  defp create_team(_) do
    team = fixture(:team)
    {:ok, team: team}
  end
end
