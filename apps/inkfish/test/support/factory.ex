defmodule Inkfish.Factory do
  use ExMachina.Ecto, repo: Inkfish.Repo
  
  alias Inkfish.Users.User
  alias Inkfish.Users.Reg
  alias Inkfish.Courses.Course
  alias Inkfish.JoinReqs.JoinReq
  alias Inkfish.Uploads.Upload
  alias Inkfish.Courses.Bucket
  
  def user_factory do
    login = sequence(:login, &"sam#{&1}")
    
    %User{
      login: login,
      email: "#{login}@example.com",
      given_name: String.capitalize(login),
      surname: "Smith",
      is_admin: false,
      nickname: "",
    }
  end
  
  def course_factory do
    %Course{
      footer: "",
      name: sequence(:name, &"CS #{&1}"),
      start_date: Date.utc_today(),
    }
  end
  
  def reg_factory do
    %Reg{
      is_grader: false,
      is_prof: false,
      is_staff: false,
      is_student: true,
      user: build(:user),
      course: build(:course),
    }
  end

  def join_req_factory do
    %JoinReq{
      course: build(:course),
      user: build(:user),
      note: "let me in",
      staff_req: false,
    }
  end

  def upload_factory do
    %Upload{
      name: "helloc.tar.gz",
      kind: "assignment_starter",
      user: build(:user),
    }
  end
  
  def bucket_factory do
    %Bucket{
      name: "Homework",
      weight: Decimal.new("1.0"),
      course: build(:course),
    }
  end
end
