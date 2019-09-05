defmodule InkfishWeb.Staff.GradeController do
  use InkfishWeb, :controller

  alias Inkfish.Grades
  alias Inkfish.Grades.Grade

  plug InkfishWeb.Plugs.FetchItem, [grade: "id"]
    when action not in [:index, :new, :create]
  plug InkfishWeb.Plugs.FetchItem, [sub: "sub_id"]
    when action in [:index, :new, :create]

  plug InkfishWeb.Plugs.RequireReg, staff: true

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {:show, :staff, :assignment}
  plug Breadcrumb, {:show, :staff, :sub}

  def index(conn, _params) do
    grades = Grades.list_grades()
    render(conn, "index.html", grades: grades)
  end

  def new(conn, _params) do
    changeset = Grades.change_grade(%Grade{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sub_id" => sub_id, "grade" => grade_params}) do
    grade_params = grade_params
    |> Map.put("sub_id", sub_id)
    |> Map.put("grading_user_id", conn.assigns[:current_user_id])

    if conn.assigns[:client_mode] == :browser do
      browser_create(conn, %{"grade" => grade_params})
    else
      ajax_create(conn, %{"grade" => grade_params})
    end
  end

  def browser_create(conn, %{"grade" => grade_params}) do
    case Grades.create_grade(grade_params) do
      {:ok, grade} ->
        Inkfish.Subs.calc_sub_score!(grade.sub_id)
        save_sub_dump!(grade.sub_id)
        redirect(conn, to: Routes.staff_grade_path(conn, :edit, grade))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Failed to create grade.")
        |> redirect(to: Routes.page_path(@conn, :dashboard))
    end
  end

  def ajax_create(conn, %{"grade" => grade_params}) do
    case Grades.create_grade(grade_params) do
      {:ok, grade} ->
        Inkfish.Subs.calc_sub_score!(grade.sub_id)
        save_sub_dump!(grade.sub_id)
        render(conn, "grade.json", grade: grade)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_resp_header("content-type", "application/json; charset=UTF-8")
        |> send_resp(500, Jason.encode!(%{error: inspect(changeset)}))
    end
  end

  def show(conn, %{"id" => id}) do
    grade = Grades.get_grade!(id)
    render(conn, "show.html", grade: grade)
  end

  def edit(conn, %{"id" => id}) do
    {id, _} = Integer.parse(id)
    grade = Grades.get_grade!(id)
    rubric = Inkfish.Uploads.get_upload(grade.grade_column.upload_id)
    changeset = Grades.change_grade(grade)
    grade_json = InkfishWeb.Staff.GradeView.render("grade.json", %{grade: grade})
    data = Inkfish.Subs.read_sub_data(grade.sub_id)
    |> Map.put(:edit, true)
    |> Map.put(:grade_id, id)
    |> Map.put(:grade, grade_json)
    render(conn, "edit.html", grade: grade, changeset: changeset,
      data: data, rubric: rubric)
  end

  def update(conn, %{"id" => id, "grade" => grade_params}) do
    grade = Grades.get_grade!(id)

    case Grades.update_grade(grade, grade_params) do
      {:ok, grade} ->
        Inkfish.Subs.calc_sub_score!(grade.sub_id)
        save_sub_dump!(grade.sub_id)

        conn
        |> put_flash(:info, "Grade updated successfully.")
        |> redirect(to: Routes.staff_grade_path(conn, :show, grade))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", grade: grade, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    grade = Grades.get_grade!(id)
    {:ok, _grade} = Grades.delete_grade(grade)

    conn
    |> put_flash(:info, "Grade deleted successfully.")
    |> redirect(to: Routes.staff_grade_path(conn, :index))
  end

  def save_sub_dump!(sub_id) do
    sub = Inkfish.Subs.get_sub!(sub_id)
    json = InkfishWeb.Staff.SubView.render("sub.json", %{sub: sub})
    |> Jason.encode!(pretty: true)
    Inkfish.Subs.save_sub_dump!(sub.id, json)
  end
end
