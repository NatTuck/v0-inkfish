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

alias Inkfish.Users.User
alias Inkfish.Users.Reg
alias Inkfish.Courses.Course
alias Inkfish.Courses.Bucket
alias Inkfish.Teams.Teamset
alias Inkfish.Assignments.Assignment

alias Inkfish.Courses
alias Inkfish.Teams

alias Inkfish.Repo

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
    {:ok, course} = Courses.create_course(%{name: name, start_date: Date.utc_today()})
    course
  end

  def reg(user, course, attrs) do
    %Reg{user_id: user.id, course_id: course.id}
    |> Map.merge(Enum.into(attrs, %{}))
    |> Repo.insert!()
  end

  def bucket(course, name, weight) do
    Repo.insert!(%Bucket{course_id: course.id, name: name, weight: weight})
  end

  def assignment(course, bucket, name) do
    ts = Teams.get_solo_teamset!(course)
    as = %Assignment{
      name: name,
      desc: name,
      due: days_from_now(3),
      weight: Decimal.new("1.0"),
      bucket_id: bucket.id,
      teamset_id: ts.id,
    }
    Repo.insert!(as)
  end

  def now do
    :calendar.local_time()
    |> NaiveDateTime.from_erl!()
    |> NaiveDateTime.truncate(:second)
  end

  def days_from_now(nn) do
    now()
    |> NaiveDateTime.add(nn*60*60*24)
    |> NaiveDateTime.truncate(:second)
  end
end

u0 = Make.user("alice")
Inkfish.Users.update_user(u0, %{is_admin: true})
u1 = Make.user("bob")
u2 = Make.user("carol")
u3 = Make.user("dave")

c0 = Make.course("Data Science of Art History")
Make.reg(u1, c0, is_prof: true)
Make.reg(u2, c0, is_staff: true)
Make.reg(u3, c0, is_student: true)

b0 = Make.bucket(c0, "Homework", Decimal.new("1.0"))
a0 = Make.assignment(c0, b0, "Homework 1")
