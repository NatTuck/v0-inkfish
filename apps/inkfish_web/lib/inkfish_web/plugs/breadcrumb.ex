defmodule InkfishWeb.Plugs.Breadcrumb do
  use InkfishWeb, :controller

  def init(args), do: args
  
  def call(conn, item) do
    crumbs = conn.assigns[:breadcrumb] || []
    conn
    |> assign(:breadcrumb, [item | crumbs])
  end
end
