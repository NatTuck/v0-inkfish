defmodule InkfishWeb.Staff.RegController do
  use InkfishWeb, :controller

  plug InkfishWeb.Plugs.FetchItem, [course: "course_id"]
    when action in [:index, :new, :create]
  plug InkfishWeb.Plugs.FetchItem, [reg: "id"]
    when action not in [:index, :new, :create]

  alias Inkfish.Users
  alias Inkfish.Users.Reg

  def index(conn, _params) do
    regs = Users.list_regs_for_course(conn.assigns[:course])
    render(conn, "index.html", regs: regs)
  end

  def new(conn, _params) do
    changeset = Users.change_reg(%Reg{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"reg" => reg_params}) do
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
    |> redirect(to: Routes.staff_reg_path(conn, :index))
  end
end
