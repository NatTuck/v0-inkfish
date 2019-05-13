defmodule InkfishWeb.PageControllerTest do
  use InkfishWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Inkfish"
    assert html_response(conn, 200) =~ "Log In"
  end
end
