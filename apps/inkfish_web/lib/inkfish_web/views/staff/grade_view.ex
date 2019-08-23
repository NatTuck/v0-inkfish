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
    %{
      score: grade.score,
      sub_id: grade.sub_id,
      grade_column_id: grade.grade_column_id,
      grader: InkfishWeb.UserView.render("user.json", user: grade.grader),
    }
  end
end

