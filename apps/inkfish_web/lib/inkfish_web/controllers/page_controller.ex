defmodule InkfishWeb.PageController do
  use InkfishWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
