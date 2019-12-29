defmodule Inkfish.Uploads.Git do
  def start_clone(url) do
    script = :code.priv_dir(:inkfish)
    |> Path.join("scripts/upload_git_clone.sh")

    {:ok, uuid} = Inkfish.Itty.start(script, REPO: url, SIZE: "5m")
    {:ok, data} = Inkfish.Itty.open(uuid)
    {:ok, uuid, data}
  end

  def get_results(uuid) do
    {:ok, text} = Inkfish.Itty.close(uuid)
    data = String.split(text, "\n", trim: true)
    |> Enum.map(fn line ->
      [key, val] = String.split(line, ~r/:\s*/, parts: 2)
      {key, val}
    end)
    |> Enum.into(%{})
    {:ok, data}
  end
end
