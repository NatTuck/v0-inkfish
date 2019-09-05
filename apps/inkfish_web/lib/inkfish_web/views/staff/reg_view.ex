defmodule InkfishWeb.Staff.RegView do
  use InkfishWeb, :view

  def render("reg.json", %{reg: reg}) do
    user = get_assoc(reg, :user)
    course = get_assoc(reg, :course)

    %{
      id: reg.id,
      is_grader: reg.is_grader,
      is_staff: reg.is_staff,
      is_prof: reg.is_prof,
      is_student: reg.is_student,
      user_id: reg.user_id,
      user: render_one(user, InkfishWeb.UserView, "user.json"),
      course_id: reg.course_id,
      course: render_one(course, InkfishWeb.Staff.CourseView, "course.json"),
    }
  end
end
