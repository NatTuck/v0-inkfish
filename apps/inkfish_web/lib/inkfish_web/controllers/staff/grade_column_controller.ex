defmodule InkfishWeb.Staff.GradeColumnController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [assignment: "assignment_id"]
    when action in [:index, :new, :create]
  plug Plugs.FetchItem, [grade_column: "id"]
    when action not in [:index, :new, :create]

  plug Plugs.RequireReg, staff: true

  alias Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {:show, :staff, :assignment}

  alias Inkfish.Grades
  alias Inkfish.Grades.GradeColumn

  def index(conn, _params) do
    grade_columns = Grades.list_grade_columns()
    render(conn, "index.html", grade_columns: grade_columns)
  end

  def new(conn, _params) do
    defaults = %GradeColumn{
      points: Decimal.new("50"),
      base: Decimal.new("50"),
    }
    changeset = Grades.change_grade_column(defaults)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"grade_column" => grade_column_params}) do
    grade_column_params = Map.put(
      grade_column_params, "assignment_id", conn.assigns[:assignment].id)

    case Grades.create_grade_column(grade_column_params) do
      {:ok, grade_column} ->
        conn
        |> put_flash(:info, "Grade_Column created successfully.")
        |> redirect(to: Routes.staff_grade_column_path(conn, :show, grade_column))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    grade_column = Grades.get_grade_column!(id)
    render(conn, "show.html", grade_column: grade_column)
  end

  def edit(conn, %{"id" => id}) do
    grade_column = Grades.get_grade_column!(id)
    changeset = Grades.change_grade_column(grade_column)
    render(conn, "edit.html", grade_column: grade_column, changeset: changeset)
  end

  def update(conn, %{"id" => id, "grade_column" => grade_column_params}) do
    grade_column = Grades.get_grade_column!(id)

    case Grades.update_grade_column(grade_column, grade_column_params) do
      {:ok, grade_column} ->
        conn
        |> put_flash(:info, "Grade_Column updated successfully.")
        |> redirect(to: Routes.staff_grade_column_path(conn, :show, grade_column))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", grade_column: grade_column, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    grade_column = Grades.get_grade_column!(id)
    {:ok, _grade_column} = Grades.delete_grade_column(grade_column)

    conn
    |> put_flash(:info, "Grade column deleted successfully.")
    |> redirect(to: Routes.staff_assignment_path(conn, :show, grade_column.assignment_id))
  end
end
