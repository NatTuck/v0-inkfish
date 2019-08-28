defmodule InkfishWeb.LayoutView do
  use InkfishWeb, :view
  
  def page_title(conn) do
    if conn.assigns[:page_title] do
      conn.assigns[:page_title]
    else
      sec = String.capitalize(current_controller(conn))
      act = String.capitalize(current_action(conn))
      if act == "Index" do
        Inflex.pluralize("List #{sec}")
      else
        "#{act} #{sec}"
      end
    end
  end
  
  def current_controller(conn) do
    mod = to_string(conn.private.phoenix_controller)
    [_, sec] = Regex.run(~r{InkfishWeb\.(?:\w+\.)?(\w+)Controller$}, mod)
    sec
  end

  def current_controller_full(conn) do
    mod = to_string(conn.private.phoenix_controller)
    [_, sec] = Regex.run(~r{InkfishWeb\.([\w\.]+)Controller$}, mod)
    sec
  end
  
  def current_action(conn) do
    to_string(conn.private.phoenix_action)
  end
  
  def current_page(conn) do
    sec = String.downcase(current_controller_full(conn))
    act = String.downcase(current_action(conn))
    "#{sec}/#{act}"
  end

  ## Breadcrumbs
  def item_type_name(item) do
    struct_name = to_string(item.__struct__)
    String.downcase(String.replace(struct_name, ~r(^.*\.), ""))
  end

  def crumb_to_link(conn, {:show, key}) do
    crumb_to_link(conn, {:show, nil, key})
  end

  def crumb_to_link(_conn, {name, path}) do
    crumb = safe_to_string(link name, to: path)
    ~s[<li class="breadcrumb-item">#{crumb}</li>]
  end

  def crumb_to_link(conn, {:show, prefix, key}) do
    item = conn.assigns[key]
    type = item_type_name(item)
    parts = Enum.filter [prefix, type, "path"], &(&1 != nil)
    func = String.to_atom(Enum.join(parts, "_"))
    path = apply(Routes, func, [conn, :show, item])
    if Map.get(item, :name) do
      crumb_to_link(conn, {item.name, path})
    else
      type_name = String.capitalize(type)
      crumb_to_link(conn, {"#{type_name} ##{item.id}", path})
    end
  end
 
  def crumb_to_link(conn, {name, helper, action}) do
    func = String.to_atom(Atom.to_string(helper) <> "_path")
    path = apply(Routes, func, [conn, action])
    crumb_to_link(conn, {name, path})
  end

  def crumb_to_link(conn, {name, helper, action, key}) do
    func = String.to_atom(Atom.to_string(helper) <> "_path")
    path = apply(Routes, func, [conn, action, conn.assigns[key]])
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
