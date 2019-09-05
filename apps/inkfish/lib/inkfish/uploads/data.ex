defmodule Inkfish.Uploads.Data do
  alias Inkfish.Uploads.Upload

  def read_data(%Upload{} = upload) do
    read_tree(Upload.unpacked_path(upload))
  end

  def read_tree(base) do
    read_tree(base, "")
  end

  def read_tree(base, rel) do
    path = Path.join(base, rel)
    {:ok, stat} = File.stat(path)
    info = %{
      key: rel,
      path: rel,
      label: label(rel),
      type: to_string(stat.type),
      size: stat.size,
    }
    read_item(base, rel, info)
  end

  def label(path) do
    if path == "" do
      "[root]"
    else
      Path.basename(path)
    end
  end

  def read_list(base, rel, items) do
    Enum.map items, fn item ->
      relp = Path.join(rel, item)
      read_tree(base, relp)
    end
  end

  def read_item(base, rel, %{type: "directory"} = info) do
    path = Path.join(base, rel)
    items = File.ls!(path)
    nodes = read_list(base, rel, items)
    Map.put(info, :nodes, nodes)
  end

  def read_item(base, rel, %{type: "regular"} = info) do
    info
    |> set_mode(base, rel)
    |> read_text(base, rel)
  end

  def read_item(base, rel, info) do
    info
  end

  def set_mode(info, base, rel) do
    name = Path.basename(rel)
    cond do
      name =~ ~r/\.ex$/i ->
        Map.put(info, :mode, "elixir")
      name =~ ~r/\.c$/i ->
        Map.put(info, :mode, "clike")
      text_file?(Path.join(base, rel)) ->
        Map.put(info, :mode, "null")
      true ->
          info
    end
  end

  def read_text(info, base, rel) do
    path = Path.join(base, rel)
    if info[:mode] do
      text = File.read!(path)
      Map.put(info, :text, text)
    else
      info
    end
  end

  def text_file?(path) do
    {type, 0} = System.cmd("file", [path])
    type =~ ~r/text/i
  end
end