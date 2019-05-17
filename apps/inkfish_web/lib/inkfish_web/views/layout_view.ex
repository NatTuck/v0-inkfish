defmodule InkfishWeb.LayoutView do
  use InkfishWeb, :view
  
  def page_title(conn) do
    if conn.assigns[:page_title] do
      conn.assigns[:page_title]
    else
      sec = String.capitalize(current_controller(conn))
      act = String.capitalize(current_action(conn))
      "#{sec} #{act}"
    end
  end
  
  def current_controller(conn) do
    mod = to_string(conn.private.phoenix_controller)
    [_, sec] = Regex.run(~r{InkfishWeb\.([\w\.]+)Controller$}, mod)
    sec
  end
  
  def current_action(conn) do
    to_string(conn.private.phoenix_action)
  end
  
  def current_page(conn) do
    sec = String.downcase(current_controller(conn))
    act = String.downcase(current_action(conn))
    "#{sec}/#{act}"
  end

  ## Breadcrumbs
  def crumb_to_link(_conn, {name, path}) do
    crumb = safe_to_string(link name, to: path)
    ~s[<li class="breadcrumb-item">#{crumb}</li>]
  end
  
  def crumb_to_link(conn, {name, helper, action}) do
    func = String.to_atom(Atom.to_string(helper) <> "_path")
    path = apply(Routes, func, [conn, action])
    crumb_to_link(conn, {name, path})
  end

  def breadcrumb(conn) do
    crumbs = Enum.reverse(conn.assigns[:breadcrumb] || [])
    items = Enum.map crumbs, &(crumb_to_link(conn, &1))
    title = page_title(conn)
   
    html = ~s[
        <ul class="breadcrumb">
          #{items}
          <li class="breadcrumb-item active">#{title}</li>
        </ul>
    ]
    raw(html)
  end
end
