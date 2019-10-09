defmodule InkfishWeb.Staff.RegController do
  use InkfishWeb, :controller

  alias InkfishWeb.Plugs
  plug Plugs.FetchItem, [course: "course_id"]
    when action in [:index, :new, :create]
  plug Plugs.FetchItem, [reg: "id"]
    when action not in [:index, :new, :create]
  plug Plugs.RequireReg, staff: true

  alias InkfishWeb.Plugs.Breadcrumb
  plug Breadcrumb, {"Courses (Staff)", :staff_course, :index}
  plug Breadcrumb, {:show, :staff, :course}
  plug Breadcrumb, {"Regs", :staff_course_reg, :index, :course}
    when action not in [:index, :new, :create]

  alias Inkfish.Users
  alias Inkfish.Users.Reg
  alias Inkfish.Courses
  alias Inkfish.Subs

  def index(conn, _params) do
    regs = Users.list_regs_for_course(conn.assigns[:course])
    render(conn, "index.html", regs: regs)
  end

  def new(conn, _params) do
    changeset = Users.change_reg(%Reg{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"reg" => reg_params}) do
    reg_params = Map.put(reg_params, "course_id", conn.assigns[:course].id)
    case Users.create_reg(reg_params) do
      {:ok, reg} ->
        conn
        |> put_flash(:info, "Reg created successfully.")
        |> redirect(to: Routes.staff_reg_path(conn, :show, reg))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    reg = Users.get_reg!(id)
    course = Courses.get_course_for_staff_view!(reg.course_id)
    subs = Enum.reduce Subs.list_subs_for_reg(reg), %{}, fn (sub, acc) ->
      xs = Map.get(acc, sub.assignment_id) || []
      Map.put(acc, sub.assignment_id, [sub | xs])
    end
    render(conn, "show.html", reg: reg, course: course, subs: subs)
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
        |> redirect(to: Routes.staff_reg_path(conn, :show, reg))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", reg: reg, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    reg = Users.get_reg!(id)
    {:ok, _reg} = Users.delete_reg(reg)

    conn
    |> put_flash(:info, "Reg deleted successfully.")
    |> redirect(to: Routes.staff_course_reg_path(conn, :index, reg.course_id))
  end
end
