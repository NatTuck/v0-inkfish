defmodule InkfishWeb.Staff.GradeView do
  use InkfishWeb, :view

  alias Inkfish.Grades.GradeColumn
  alias Inkfish.Grades.Grade

  def staff_grade_action(sub, %GradeColumn{kind: "number"} = _gcol, nil) do
    link "New Grade", to: Routes.staff_grade_path(@conn, :new, sub)
  end

  def staff_grade_action(sub, %GradeColumn{kind: "feedback"} = _gcol, nil) do
    "new grade"
  end

  def staff_grade_action(sub, %GradeColumn{kind: "script"} = _gcol, nil) do
    "run script"
  end

  def staff_grade_action(sub, %GradeColumn{} = _gcol, %Grade{} = grade) do
    "edit"
  end

  def render("grade.json", %{grade: grade}) do
    grader = get_assoc(grade, :grader)
    gc = get_assoc(grade, :grade_column)
    lcs = get_assoc(grade, :line_comments) || []

    %{
      score: grade.score,
      sub_id: grade.sub_id,
      grader_id: grade.grader_id,
      grader: render_one(grader, InkfishWeb.UserView, "user.json"),
      grade_column_id: grade.grade_column_id,
      grade_column: render_one(gc, InkfishWeb.GradeColumnView, "grade_column.json"),
      line_comments: render_many(lcs, InkfishWeb.Staff.LineCommentView, "line_comment.json")
    }
  end
end

