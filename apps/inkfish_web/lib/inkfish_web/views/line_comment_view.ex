defmodule InkfishWeb.LineCommentView do
  use InkfishWeb, :view
  alias InkfishWeb.LineCommentView

  def render("index.json", %{line_comments: line_comments}) do
    %{data: render_many(line_comments, LineCommentView, "line_comment.json")}
  end

  def render("show.json", %{line_comment: line_comment}) do
    %{data: render_one(line_comment, LineCommentView, "line_comment.json")}
  end

  def render("line_comment.json", %{line_comment: line_comment}) do
    %{id: line_comment.id,
      path: line_comment.path,
      line: line_comment.line,
      points: line_comment.points,
      text: line_comment.text}
  end
end
