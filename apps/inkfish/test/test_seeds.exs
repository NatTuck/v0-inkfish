# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Inkfish.Repo.insert!(%Inkfish.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Inkfish.Repo

alias Inkfish.Users.User
alias Inkfish.Users.Reg
alias Inkfish.Courses.Course
alias Inkfish.Courses.Bucket
alias Inkfish.Assignments.Assignment

defmodule Make do
  def user(name, admin \\ false) do
    name = String.downcase(name)
    user = %User{
      login: name,
      given_name: String.capitalize(name),
      surname: "Anderson", 
      email: "#{name}@example.com",
      is_admin: admin,
    } 
    
    Repo.insert!(user)
  end

  def course(name) do
    Repo.insert!(%Course{name: name, start_date: Date.utc_today()})
  end

  def reg(user, course, attrs) do
    %Reg{user_id: user.id, course_id: course.id}
    |> Map.merge(Enum.into(attrs, %{}))
    |> Repo.insert!()
  end

  def bucket(course, name, weight) do
    %Bucket{course_id: course.id, name: name, weight: weight}
    |> Repo.insert!()
  end

  def assignment(bucket, name) do
    course = Inkfish.Courses.get_course!(bucket.course_id)
    %Assignment{
      bucket_id: bucket.id,
      name: name,
      teamset_id: course.solo_teamset_id,
      weight: Decimal.new(1),
    }
    |> Repo.insert!()
  end
end

u0 = Make.user("alice")
Inkfish.Users.update_user(u0, %{is_admin: true})
u1 = Make.user("bob")
u2 = Make.user("carol")
u3 = Make.user("dave")
_u4 = Make.user("erin")
_u5 = Make.user("frank")

c0 = Make.course("Data Science of Art History")
#_c1 = Make.course("Machine Learning with Baroque Pottery")

Make.reg(u1, c0, is_prof: true)
Make.reg(u2, c0, is_staff: true)
Make.reg(u3, c0, is_student: true)

b0 = Make.bucket(c0, "Homework", Decimal.new("1.0"))
_a1 = Make.assignment(b0, "HW01")
