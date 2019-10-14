defmodule InkfishWeb.Admin.UploadControllerTest do
  use InkfishWeb.ConnCase

  describe "index" do
    test "lists all uploads", %{conn: conn} do
      conn = conn
      |> login("alice")
      |> get(Routes.admin_upload_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Uploads"
    end
  end
end
