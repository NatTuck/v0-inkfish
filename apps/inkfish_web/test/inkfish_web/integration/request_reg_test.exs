defmodule InkfishWeb.RequestRegTest do
  use InkfishWeb.IntegrationCase, async: true

  @tag :skip
  test "Request registration flow", %{conn: conn} do
    get(conn, "/")
    |> follow_form(
      %{
        login: "gail",
        password: "test",
      }
    )
    |> assert_response(status: 200, html: "Logged in as gail@example.com")
    |> follow_link("List All Courses")
    |> follow_link("Request to Join")
    |> assert_response(status: 200, html: "Data Science of Art History")
    |> follow_form(
      %{
        join_req: %{
          note: "test join req flow",
        }
      }
    )
    |> assert_response(status: 200, html: "Join req created successfully")
    |> assert_response(html: "Waiting for approval")
    |> follow_link("Logout", method: :delete)
    |> follow_form(
      %{
        login: "bob",
        password: "test"
      }
    )
    |> assert_response(status: 200, html: "Logged in as bob@example.com")
    |> follow_link("Staff View")
    |> follow_link("View Reqs")
    |> assert_response(status: 200, html: "test join req flow")
    |> follow_link("Accept", method: :post)
    |> assert_response(status: 200, html: "Join req accepted")
    |> follow_link("Logout", method: :delete)
    |> follow_form(
      %{
        login: "gail",
        password: "test",
      }
    )
    |> assert_response(status: 200, html: "Logged in as gail@example.com")
    |> follow_link("Data Science of Art History")
    |> assert_response(status: 200, html: "Show Course")
  end
end
