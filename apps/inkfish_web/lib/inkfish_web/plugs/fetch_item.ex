defmodule InkfishWeb.Plugs.FetchItem do
  use InkfishWeb, :controller

  alias Inkfish.Repo
  
  def init(args), do: args
 
  def call(conn, [{target, param}]) do
    id = conn.params[to_string(param)]
    fetch(conn, target, id)
  end

  def fetch(_, target, nil) do
    raise "Can't fetch nil #{target}"
  end
  
  def fetch(conn, :user, id) do
    user = Inkfish.Users.get_user!(id)
    assign(conn, :user, user)
  end

  def fetch(conn, :course, id) do
    course = Inkfish.Courses.get_course!(id)
    assign(conn, :course, course)
  end
 
  def fetch(conn, :reg, id) do
    reg = Inkfish.Users.get_reg_path!(id)
    conn
    |> assign(:reg, reg)
    |> assign(:course, reg.course)
  end

  def fetch(conn, :join_req, id) do
    req = Inkfish.JoinReqs.get_join_req_path!(id)
    conn
    |> assign(:join_req, req)
    |> assign(:course, req.course)
  end

  def fetch(conn, :teamset, id) do
    ts = Inkfish.Teams.get_teamset_path!(id)
    conn
    |> assign(:teamset, ts)
    |> assign(:course, ts.course)
  end

  def fetch(conn, :bucket, id) do
    bucket = Inkfish.Courses.get_bucket_path!(id)
    conn
    |> assign(:bucket, bucket)
    |> assign(:course, bucket.course)
  end

  def fetch(conn, :assignment, id) do
    as = Inkfish.Assignments.get_assignment_path!(id)
    conn
    |> assign(:assignment, as)
    |> assign(:bucket, as.bucket)
    |> assign(:course, as.bucket.course)
  end

  def fetch(conn, :grader, id) do
    grader = Inkfish.Grades.get_grader_path!(id)
    conn
    |> assign(:grader, grader)
    |> assign(:assignment, grader.assignment)
    |> assign(:bucket, grader.assignment.bucket)
    |> assign(:course, grader.assignment.bucket.course)
  end

  def fetch(conn, :sub, id) do
    sub = Inkfish.Subs.get_sub_path!(id)
    conn
    |> assign(:sub, sub)
    |> assign(:assignment, sub.assignment)
    |> assign(:bucket, sub.assignment.bucket)
    |> assign(:course, sub.assignment.bucket.course)
  end
end
