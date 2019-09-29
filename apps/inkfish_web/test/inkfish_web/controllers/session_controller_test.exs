defmodule InkfishWeb.SessionControllerTest do
  use InkfishWeb.ConnCase
  
  test "log in", %{conn: conn} do
    conn = post(conn, "/session", %{"login" => "alice", "password" => "test"})
    assert get_flash(conn, :info) == "Logged in as alice@example.com"
    assert redirected_to(conn, 302) == "/dashboard"
  end
  
  test "log out", %{conn: conn} do
    conn = conn
    |> login("alice")
    |> delete("/session")
    assert get_flash(conn, :info) == "Logged out."
    assert get_session(conn, :user_id) == nil
  end
end
