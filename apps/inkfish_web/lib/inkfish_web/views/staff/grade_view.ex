defmodule InkfishWeb.Staff.GradeView do
  use InkfishWeb, :view

  alias Inkfish.Grades.Grader
  alias Inkfish.Grades.Grade

  def staff_grade_action(sub, %Grader{kind: "number"} = grader, nil) do
    link "New Grade", to: Routes.staff_grade_path(@conn, :new, sub)
  end

  def staff_grade_action(sub, %Grader{kind: "feedback"} = grader, nil) do
    "new grade"
  end

  def staff_grade_action(sub, %Grader{kind: "script"} = grader, nil) do
    "run script"
  end

  def staff_grade_action(sub, %Grader{} = grader, %Grade{} = grade) do
    "edit"
  end

  def render("grade.json", %{grade: grade}) do
    %{
      score: grade.score,
      sub_id: grade.sub_id,
      grader_id: grade.grader_id,
      grading_user: InkfishWeb.UserView.render("user.json", user: grade.grading_user),
    }
  end
end

# <%= link "Edit Grade", to: Routes.staff_grade_path(@conn, :edit, grade) %>
# <%= link "Edit Grade", to: Routes.staff_grade_path(@conn, :edit, grade) %>
# <%= link("Rerun Script", to: Routes.staff_grade_path(@conn, :edit, grade),
