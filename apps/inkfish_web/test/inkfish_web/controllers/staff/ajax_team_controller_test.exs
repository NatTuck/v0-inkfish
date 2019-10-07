defmodule InkfishWeb.Ajax.TeamControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  alias Inkfish.Teams.Team

  setup %{conn: conn} do
    course = insert(:course)
    staff = insert(:user)
    _reg = insert(:reg, course: course, user: staff, is_staff: true)
    teamset = insert(:teamset, course: course)
    team = insert(:team, teamset: teamset)
    Enum.each [1..2], fn _ ->
      memb = insert(:reg, course: course, is_student: true)
      _ = insert(:team_member, team: team, reg: memb)
    end

    {:ok, staff: staff, teamset: teamset, team: team, course: course,
     conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all teams", %{conn: conn, staff: staff, teamset: teamset} do
      conn = conn
      |> login(staff.login)
      |> get(Routes.ajax_staff_teamset_team_path(conn, :index, teamset))

      resp = json_response(conn, 200)["data"]
      assert hd(resp)["active"] == true
    end
  end

  describe "create team" do
    test "renders team when data is valid", %{conn: conn, teamset: teamset, course: course, staff: staff} do
      attrs = params_for(:team, teamset: teamset)
      reg_ids = Enum.map([1..2], fn _ -> insert(:reg, course: course).id end)
      attrs = Map.put(attrs, :reg_ids, reg_ids)

      conn = conn
      |> login(staff.login)
      |> post(Routes.ajax_staff_teamset_team_path(conn, :create, teamset), team: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.ajax_staff_team_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, teamset: teamset, staff: staff} do
      params = %{teamset_id: -1}
     
      conn = conn
      |> login(staff.login)
      |> post(Routes.ajax_staff_teamset_team_path(conn, :create, teamset), team: params)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update team" do
    test "renders team when data is valid", %{conn: conn, team: %Team{id: id} = team, staff: staff} do
      params = %{active: false}

      conn = conn
      |> login(staff.login)
      |> put(Routes.ajax_staff_team_path(conn, :update, team), team: params)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.ajax_staff_team_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, team: team, staff: staff} do
      params = %{teamset_id: -1}

      conn = conn
      |> login(staff.login)
      |> put(Routes.ajax_staff_team_path(conn, :update, team), team: params)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete team" do
    test "deletes chosen team", %{conn: conn, team: team, staff: staff} do
      conn = conn
      |> login(staff.login)
      |> delete(Routes.ajax_staff_team_path(conn, :delete, team))
      assert response(conn, 200)

      assert_error_sent 404, fn ->
        get(conn, Routes.ajax_staff_team_path(conn, :show, team))
      end
    end
  end
end
