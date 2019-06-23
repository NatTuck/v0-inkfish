defmodule Inkfish.Uploads.Cleanup do
  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Uploads
  alias Inkfish.Uploads.Upload

  def cleanup() do
    []
    |> Enum.concat(garbage_user_photos())
    |> Enum.concat(garbage_assignment_starters())
    |> Enum.concat(garbage_assignment_solutions())
    |> Enum.each(&Uploads.delete_upload/1)
  end

  def garbage_user_photos() do
    Repo.all from up in Upload,
      left_join: photo_user in assoc(up, :photo_user),
      preload: [photo_user: photo_user],
      where: up.kind == "user_photo",
      where: is_nil(photo_user.id),
      where: up.inserted_at < fragment("now()::timestamp - interval '1 hours'")
  end

  def garbage_assignment_starters() do
    Repo.all from up in Upload,
      left_join: as in assoc(up, :starter_assignment),
      preload: [starter_assignment: as],
      where: up.kind == "assignment_starter",
      where: is_nil(as.id),
      where: up.inserted_at < fragment("now()::timestamp - interval '1 hours'")
  end

  def garbage_assignment_solutions() do
    Repo.all from up in Upload,
      left_join: as in assoc(up, :solution_assignment),
      preload: [solution_assignment: as],
      where: up.kind == "assignment_solution",
      where: is_nil(as.id),
      where: up.inserted_at < fragment("now()::timestamp - interval '1 hours'")
  end
end
