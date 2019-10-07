defmodule InkfishWeb.AssignmentControllerTest do
  use InkfishWeb.ConnCase
  import Inkfish.Factory

  def fixture(:assignment) do
    insert(:assignment)
  end

  defp create_assignment(_) do
    assignment = fixture(:assignment)
    {:ok, assignment: assignment}
  end

  describe "show assignment" do
    setup [:create_assignment]

    test "show chosen assignment", %{conn: conn, assignment: assignment} do
      conn = conn
      |> login("alice")
      |> get(Routes.assignment_path(conn, :show, assignment))
      assert html_response(conn, 200) =~ "Show Assignment"
    end
  end
end
