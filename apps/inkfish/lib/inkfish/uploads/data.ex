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
    Enum.map(items, fn item ->
      relp = Path.join(rel, item)
      read_tree(base, relp)
    end)
  end

  def add_xtra_file(nodes, rel) do
    if rel == "" do
      name = "Ω_grading_extra.txt"
      text = """
      Bonus file for extra grading space.
      - one
      - two
      - green
      - lemon
      """
      xtra = %{
        key: name,
        path: name,
        label: name,
        type: "text/plain",
        size: String.length(text),
        text: text,
      }
      [xtra | nodes]
    else
      nodes
    end
  end

  def read_item(base, rel, %{type: "directory"} = info) do
    path = Path.join(base, rel)
    items = File.ls!(path)
    nodes = read_list(base, rel, items)
    |> add_xtra_file(rel)
    |> Enum.sort_by(&(&1.path))
    Map.put(info, :nodes, nodes)
  end

  def read_item(base, rel, %{type: "regular"} = info) do
    info
    |> set_mode(base, rel)
    |> read_text(base, rel)
  end

  def read_item(_base, _rel, info) do
    info
  end

  def set_mode(info, base, rel) do
    name = Path.basename(rel)



    cond do
      info.size > 4096 ->
        info
      name =~ ~r/^\./ ->
        info
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
    if info[:mode] && text_file?(path) do
      text = File.read!(path)
      Map.put(info, :text, text)
    else
      info
    end
  end

  def text_file?(path) do
    {type, 0} = System.cmd("file", ["-ib", path])
    type =~ ~r/^text/i
  end
end
