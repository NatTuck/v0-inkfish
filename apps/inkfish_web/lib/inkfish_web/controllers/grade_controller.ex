defmodule InkfishWeb.GradeController do
  use InkfishWeb, :controller

  alias Inkfish.Grades
  alias Inkfish.Grades.Grade

  plug InkfishWeb.Plugs.FetchItem, [grade: "id"]
    when action not in [:index, :new, :create]

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses", :course, :index}
  plug Breadcrumb, {:show, :course}
  plug Breadcrumb, {:show, :assignment}
  plug Breadcrumb, {:show, :sub}

  def index(conn, _params) do
    grades = Grades.list_grades()
    render(conn, "index.html", grades: grades)
  end

  def new(conn, _params) do
    changeset = Grades.change_grade(%Grade{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"grade" => grade_params}) do
    case Grades.create_grade(grade_params) do
      {:ok, grade} ->
        conn
        |> put_flash(:info, "Grade created successfully.")
        |> redirect(to: Routes.grade_path(conn, :show, grade))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    grade = Grades.get_grade!(id)


    {id, _} = Integer.parse(id)
    grade_json = InkfishWeb.Staff.GradeView.render("grade.json", %{grade: grade})
    data = Inkfish.Subs.read_sub_data(grade.sub_id)
    |> Map.put(:edit, false)
    |> Map.put(:grade_id, id)
    |> Map.put(:grade, grade_json)
    render(conn, "show.html", grade: grade, data: data)
  end

  def edit(conn, %{"id" => id}) do
    grade = Grades.get_grade!(id)
    changeset = Grades.change_grade(grade)
    render(conn, "edit.html", grade: grade, changeset: changeset)
  end

  def update(conn, %{"id" => id, "grade" => grade_params}) do
    grade = Grades.get_grade!(id)

    case Grades.update_grade(grade, grade_params) do
      {:ok, grade} ->
        conn
        |> put_flash(:info, "Grade updated successfully.")
        |> redirect(to: Routes.grade_path(conn, :show, grade))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", grade: grade, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    grade = Grades.get_grade!(id)
    {:ok, _grade} = Grades.delete_grade(grade)

    conn
    |> put_flash(:info, "Grade deleted successfully.")
    |> redirect(to: Routes.grade_path(conn, :index))
  end
end
