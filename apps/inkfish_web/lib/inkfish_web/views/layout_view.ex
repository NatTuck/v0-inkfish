defmodule InkfishWeb.LayoutView do
  use InkfishWeb, :view

  def page_title(conn) do
    if conn.assigns[:page_title] do
      conn.assigns[:page_title]
    else
      mod = to_string(conn.private.phoenix_controller)
      [_, sec] = Regex.run(~r[\.(\w+)Controller$], mod)
      act = to_string(conn.private.phoenix_action)
      "#{sec} #{act}"
    end
  end
  
  def breadcrumb(conn) do
    [last|rest] = Enum.reverse(conn.assigns[:breadcrumb] || [{"Home", "/"}])
    items = Enum.map Enum.reverse(rest), fn {text, path} ->
      crumb = link(text, to: path)
      ~s[<li class="breadcrumb-item">#{crumb}</li>]
    end
    ~s[<ul class="breadcrumb">#{items}</ul>]
  end
end
