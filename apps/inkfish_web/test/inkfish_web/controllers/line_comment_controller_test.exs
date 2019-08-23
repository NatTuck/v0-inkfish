defmodule InkfishWeb.LineCommentControllerTest do
  use InkfishWeb.ConnCase

  alias Inkfish.LineComments
  alias Inkfish.LineComments.LineComment

  @create_attrs %{
    line: 42,
    path: "some path",
    points: "120.5",
    text: "some text"
  }
  @update_attrs %{
    line: 43,
    path: "some updated path",
    points: "456.7",
    text: "some updated text"
  }
  @invalid_attrs %{line: nil, path: nil, points: nil, text: nil}

  def fixture(:line_comment) do
    {:ok, line_comment} = LineComments.create_line_comment(@create_attrs)
    line_comment
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all line_comments", %{conn: conn} do
      conn = get(conn, Routes.line_comment_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create line_comment" do
    test "renders line_comment when data is valid", %{conn: conn} do
      conn = post(conn, Routes.line_comment_path(conn, :create), line_comment: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.line_comment_path(conn, :show, id))

      assert %{
               "id" => id,
               "line" => 42,
               "path" => "some path",
               "points" => "120.5",
               "text" => "some text"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.line_comment_path(conn, :create), line_comment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update line_comment" do
    setup [:create_line_comment]

    test "renders line_comment when data is valid", %{conn: conn, line_comment: %LineComment{id: id} = line_comment} do
      conn = put(conn, Routes.line_comment_path(conn, :update, line_comment), line_comment: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.line_comment_path(conn, :show, id))

      assert %{
               "id" => id,
               "line" => 43,
               "path" => "some updated path",
               "points" => "456.7",
               "text" => "some updated text"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, line_comment: line_comment} do
      conn = put(conn, Routes.line_comment_path(conn, :update, line_comment), line_comment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete line_comment" do
    setup [:create_line_comment]

    test "deletes chosen line_comment", %{conn: conn, line_comment: line_comment} do
      conn = delete(conn, Routes.line_comment_path(conn, :delete, line_comment))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.line_comment_path(conn, :show, line_comment))
      end
    end
  end

  defp create_line_comment(_) do
    line_comment = fixture(:line_comment)
    {:ok, line_comment: line_comment}
  end
end
