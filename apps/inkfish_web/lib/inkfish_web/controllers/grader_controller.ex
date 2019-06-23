defmodule InkfishWeb.GraderController do
  use InkfishWeb, :controller

  alias Inkfish.Grades
  alias Inkfish.Grades.Grader

  def index(conn, _params) do
    graders = Grades.list_graders()
    render(conn, "index.html", graders: graders)
  end

  def new(conn, _params) do
    changeset = Grades.change_grader(%Grader{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"grader" => grader_params}) do
    case Grades.create_grader(grader_params) do
      {:ok, grader} ->
        conn
        |> put_flash(:info, "Grader created successfully.")
        |> redirect(to: Routes.grader_path(conn, :show, grader))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    grader = Grades.get_grader!(id)
    render(conn, "show.html", grader: grader)
  end

  def edit(conn, %{"id" => id}) do
    grader = Grades.get_grader!(id)
    changeset = Grades.change_grader(grader)
    render(conn, "edit.html", grader: grader, changeset: changeset)
  end

  def update(conn, %{"id" => id, "grader" => grader_params}) do
    grader = Grades.get_grader!(id)

    case Grades.update_grader(grader, grader_params) do
      {:ok, grader} ->
        conn
        |> put_flash(:info, "Grader updated successfully.")
        |> redirect(to: Routes.grader_path(conn, :show, grader))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", grader: grader, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    grader = Grades.get_grader!(id)
    {:ok, _grader} = Grades.delete_grader(grader)

    conn
    |> put_flash(:info, "Grader deleted successfully.")
    |> redirect(to: Routes.grader_path(conn, :index))
  end
end
