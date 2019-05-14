 defmodule InkfishWeb.Plugs.Breadcrumb do
  use InkfishWeb, :controller

  def init(args), do: args
  
  def call(conn, [{:base, base}]) do
    conn
    |> assign(:breadcrumb, base)
  end
end
