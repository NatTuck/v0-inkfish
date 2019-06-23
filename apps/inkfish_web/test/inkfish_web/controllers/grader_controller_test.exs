defmodule InkfishWeb.GraderControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.Grades

  @create_attrs %{kind: "some kind", name: "some name", params: "some params", points: "120.5", weight: "120.5"}
  @update_attrs %{kind: "some updated kind", name: "some updated name", params: "some updated params", points: "456.7", weight: "456.7"}
  @invalid_attrs %{kind: nil, name: nil, params: nil, points: nil, weight: nil}

  def fixture(:grader) do
    {:ok, grader} = Grades.create_grader(@create_attrs)
    grader
  end

  describe "index" do
    test "lists all graders", %{conn: conn} do
      conn = get(conn, Routes.grader_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Graders"
    end
  end

  describe "new grader" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.grader_path(conn, :new))
      assert html_response(conn, 200) =~ "New Grader"
    end
  end

  describe "create grader" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.grader_path(conn, :create), grader: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.grader_path(conn, :show, id)

      conn = get(conn, Routes.grader_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Grader"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.grader_path(conn, :create), grader: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Grader"
    end
  end

  describe "edit grader" do
    setup [:create_grader]

    test "renders form for editing chosen grader", %{conn: conn, grader: grader} do
      conn = get(conn, Routes.grader_path(conn, :edit, grader))
      assert html_response(conn, 200) =~ "Edit Grader"
    end
  end

  describe "update grader" do
    setup [:create_grader]

    test "redirects when data is valid", %{conn: conn, grader: grader} do
      conn = put(conn, Routes.grader_path(conn, :update, grader), grader: @update_attrs)
      assert redirected_to(conn) == Routes.grader_path(conn, :show, grader)

      conn = get(conn, Routes.grader_path(conn, :show, grader))
      assert html_response(conn, 200) =~ "some updated kind"
    end

    test "renders errors when data is invalid", %{conn: conn, grader: grader} do
      conn = put(conn, Routes.grader_path(conn, :update, grader), grader: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Grader"
    end
  end

  describe "delete grader" do
    setup [:create_grader]

    test "deletes chosen grader", %{conn: conn, grader: grader} do
      conn = delete(conn, Routes.grader_path(conn, :delete, grader))
      assert redirected_to(conn) == Routes.grader_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.grader_path(conn, :show, grader))
      end
    end
  end

  defp create_grader(_) do
    grader = fixture(:grader)
    {:ok, grader: grader}
  end
end
