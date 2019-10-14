defmodule InkfishWeb.Staff.LineCommentView do
  use InkfishWeb, :view
  alias InkfishWeb.Staff.LineCommentView

  def render_list(line_comments) do
    render_many(line_comments, LineCommentView, "line_comment.json")
  end

  def render("index.json", %{line_comments: line_comments}) do
    %{data: render_many(line_comments, LineCommentView, "line_comment.json")}
  end

  def render("show.json", %{line_comment: line_comment}) do
    %{data: render_one(line_comment, LineCommentView, "line_comment.json")}
  end

  def render("line_comment.json", %{line_comment: line_comment}) do
    user = get_assoc(line_comment, :user)
    user_json = render_one(user, InkfishWeb.UserView, "user.json")

    grade = get_assoc(line_comment, :grade)
    grade_json = render_one(grade, InkfishWeb.Staff.GradeView, "grade.json")

    %{id: line_comment.id,
      path: line_comment.path,
      line: line_comment.line,
      points: line_comment.points,
      text: line_comment.text,
      user_id: line_comment.user_id,
      user: user_json,
      grade_id: line_comment.grade_id,
      grade: grade_json,
    }
  end
end
