defmodule InkfishWeb.RegController do
  use InkfishWeb, :controller

  alias Inkfish.Users
  alias Inkfish.Users.Reg
  
  plug InkfishWeb.Plugs.FetchCourse, only: [:index, :new, :create]

  def index(conn, %{"course_id" => course_id}) do
    regs = Users.list_regs_for_course(course_id)
    render(conn, "index.html", course_id: course_id, regs: regs)
  end

  def new(conn, %{"course_id" => course_id}) do
    changeset = Users.change_reg(%Reg{course_id: course_id})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"course_id" => course_id, "reg" => reg_params}) do
    reg_params = Map.put(reg_params, "course_id", course_id)
    case Users.create_reg(reg_params) do
      {:ok, reg} ->
        conn
        |> put_flash(:info, "Reg created successfully.")
        |> redirect(to: Routes.reg_path(conn, :show, reg))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    reg = Users.get_reg!(id)
    render(conn, "show.html", reg: reg)
  end

  def edit(conn, %{"id" => id}) do
    reg = Users.get_reg!(id)
    changeset = Users.change_reg(reg)
    render(conn, "edit.html", reg: reg, changeset: changeset)
  end

  def update(conn, %{"id" => id, "reg" => reg_params}) do
    reg = Users.get_reg!(id)

    case Users.update_reg(reg, reg_params) do
      {:ok, reg} ->
        conn
        |> put_flash(:info, "Reg updated successfully.")
        |> redirect(to: Routes.reg_path(conn, :show, reg))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", reg: reg, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    reg = Users.get_reg!(id)
    {:ok, _reg} = Users.delete_reg(reg) 

    conn
    |> put_flash(:info, "Reg deleted successfully.")
    |> redirect(to: Routes.course_reg_path(conn, :index, reg.course_id))
  end
end

