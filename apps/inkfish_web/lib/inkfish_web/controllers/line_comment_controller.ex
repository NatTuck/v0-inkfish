defmodule InkfishWeb.LineCommentController do
  use InkfishWeb, :controller

  alias Inkfish.LineComments
  alias Inkfish.LineComments.LineComment

  action_fallback InkfishWeb.FallbackController

  def index(conn, _params) do
    line_comments = LineComments.list_line_comments()
    render(conn, "index.json", line_comments: line_comments)
  end

  def create(conn, %{"line_comment" => line_comment_params}) do
    with {:ok, %LineComment{} = line_comment} <- LineComments.create_line_comment(line_comment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.line_comment_path(conn, :show, line_comment))
      |> render("show.json", line_comment: line_comment)
    end
  end

  def show(conn, %{"id" => id}) do
    line_comment = LineComments.get_line_comment!(id)
    render(conn, "show.json", line_comment: line_comment)
  end

  def update(conn, %{"id" => id, "line_comment" => line_comment_params}) do
    line_comment = LineComments.get_line_comment!(id)

    with {:ok, %LineComment{} = line_comment} <- LineComments.update_line_comment(line_comment, line_comment_params) do
      render(conn, "show.json", line_comment: line_comment)
    end
  end

  def delete(conn, %{"id" => id}) do
    line_comment = LineComments.get_line_comment!(id)

    with {:ok, %LineComment{}} <- LineComments.delete_line_comment(line_comment) do
      send_resp(conn, :no_content, "")
    end
  end
end
