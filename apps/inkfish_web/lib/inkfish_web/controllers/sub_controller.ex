defmodule InkfishWeb.SubController do
  use InkfishWeb, :controller

  alias Inkfish.Subs
  alias Inkfish.Subs.Sub

  def index(conn, _params) do
    subs = Subs.list_subs()
    render(conn, "index.html", subs: subs)
  end

  def new(conn, _params) do
    changeset = Subs.change_sub(%Sub{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sub" => sub_params}) do
    case Subs.create_sub(sub_params) do
      {:ok, sub} ->
        conn
        |> put_flash(:info, "Sub created successfully.")
        |> redirect(to: Routes.sub_path(conn, :show, sub))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sub = Subs.get_sub!(id)
    render(conn, "show.html", sub: sub)
  end

  def edit(conn, %{"id" => id}) do
    sub = Subs.get_sub!(id)
    changeset = Subs.change_sub(sub)
    render(conn, "edit.html", sub: sub, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sub" => sub_params}) do
    sub = Subs.get_sub!(id)

    case Subs.update_sub(sub, sub_params) do
      {:ok, sub} ->
        conn
        |> put_flash(:info, "Sub updated successfully.")
        |> redirect(to: Routes.sub_path(conn, :show, sub))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sub: sub, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sub = Subs.get_sub!(id)
    {:ok, _sub} = Subs.delete_sub(sub)

    conn
    |> put_flash(:info, "Sub deleted successfully.")
    |> redirect(to: Routes.sub_path(conn, :index))
  end
end
