defmodule InkfishWeb.TeamMemberControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Teams
  alias Inkfish.Teams.TeamMember

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:team_member) do
    {:ok, team_member} = Teams.create_team_member(@create_attrs)
    team_member
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all team_members", %{conn: conn} do
      conn = get(conn, Routes.team_member_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create team_member" do
    test "renders team_member when data is valid", %{conn: conn} do
      conn = post(conn, Routes.team_member_path(conn, :create), team_member: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.team_member_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.team_member_path(conn, :create), team_member: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update team_member" do
    setup [:create_team_member]

    test "renders team_member when data is valid", %{conn: conn, team_member: %TeamMember{id: id} = team_member} do
      conn = put(conn, Routes.team_member_path(conn, :update, team_member), team_member: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.team_member_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, team_member: team_member} do
      conn = put(conn, Routes.team_member_path(conn, :update, team_member), team_member: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete team_member" do
    setup [:create_team_member]

    test "deletes chosen team_member", %{conn: conn, team_member: team_member} do
      conn = delete(conn, Routes.team_member_path(conn, :delete, team_member))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.team_member_path(conn, :show, team_member))
      end
    end
  end

  defp create_team_member(_) do
    team_member = fixture(:team_member)
    {:ok, team_member: team_member}
  end
end
