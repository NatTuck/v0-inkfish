defmodule InkfishWeb.Staff.LineCommentController do
  use InkfishWeb, :controller

  alias Inkfish.LineComments
  alias Inkfish.LineComments.LineComment

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [line_comment: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.FetchItem, [grade: "grade_id"]
    when action in [:index, :new, :create]

  plug Plugs.RequireReg, staff: true

  action_fallback InkfishWeb.FallbackController

  def index(conn, %{"grade_id" => grade_id}) do
    line_comments = LineComments.list_line_comments(grade_id)
    render(conn, "index.json", line_comments: line_comments)
  end

  def create(conn, %{"line_comment" => lc_params}) do
    lc_params = lc_params
    |> Map.put("user_id", conn.assigns[:current_user].id)

    with {:ok, %LineComment{} = lc} <- LineComments.create_line_comment(lc_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.ajax_staff_line_comment_path(conn, :show, lc))
      |> render("show.json", line_comment: lc)
    end
  end

  def show(conn, %{"id" => _id}) do
    line_comment = conn.assigns[:line_comment]
    render(conn, "show.json", line_comment: line_comment)
  end

  def update(conn, %{"id" => _id, "line_comment" => line_comment_params}) do
    line_comment = conn.assigns[:line_comment]

    with {:ok, %LineComment{} = line_comment} <- LineComments.update_line_comment(line_comment, line_comment_params) do
      render(conn, "show.json", line_comment: line_comment)
    end
  end

  def delete(conn, %{"id" => _id}) do
    line_comment = conn.assigns[:line_comment]

    with {:ok, %LineComment{}} <- LineComments.delete_line_comment(line_comment) do
      # Get updated grade, with all line comments, after delete.
      grade = Inkfish.Grades.get_grade!(line_comment.grade_id)
      render(conn, "show.json", line_comment: %{line_comment | grade: grade})
    end
  end
end
