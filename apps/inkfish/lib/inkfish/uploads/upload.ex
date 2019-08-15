defmodule Inkfish.Uploads.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inkfish.Uploads.Photo

  @primary_key {:id, :binary_id, autogenerate: true}

  @valid_kinds ["user_photo", "grader", "sub",
                "assignment_starter", "assignment_solution"]

  schema "uploads" do
    field :name, :string
    field :kind, :string
    belongs_to :user, Inkfish.Users.User

    has_one :photo_user, Inkfish.Users.User, foreign_key: :photo_upload_id
    has_one :starter_assignment, Inkfish.Assignments.Assignment,
      foreign_key: :starter_upload_id
    has_one :solution_assignment, Inkfish.Assignments.Assignment,
      foreign_key: :solution_upload_id
    has_one :sub, Inkfish.Subs.Sub

    field :upload, :any, virtual: true

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    # Uploads are immutable, so all changesets are new inserts.
    upload
    |> cast(attrs, [:upload, :kind, :user_id])
    |> normalize_name()
    |> validate_required([:upload, :kind, :user_id, :name])
    |> validate_kind()
    |> validate_file_size()
  end

  def normalize_name(%Ecto.Changeset{} = cset) do
    if upload = get_field(cset, :upload) do
      name = String.replace(upload.filename, ~r([^\w\.]+), "_")
      put_change(cset, :name, name)
    else
      cset
    end
  end

  def validate_kind(%Ecto.Changeset{} = cset) do
    kind = get_field(cset, :kind)
    if Enum.member?(@valid_kinds, kind) do
      cset
    else
      add_error(cset, :kind, "invalid upload kind: #{kind}")
    end
  end

  def validate_file_size(%Ecto.Changeset{} = cset) do
    upload = get_field(cset, :upload)
    {:ok, stat} = File.stat(upload.path)
    if stat.size > 10_485_760 do
      add_error(cset, :upload, "uploaded file is too big")
    else
      cset
    end
  end

  def save_upload_file!(cset, %{kind: "user_photo"} = upload) do
    up = get_field(cset, :upload)
    Photo.resize_photo!(up.path, upload_path(upload), 960, 960)
    Photo.resize_photo!(upload_path(upload), Photo.thumb_path(upload), 200, 200)
  end

  def save_upload_file!(cset, upload) do
    up = get_field(cset, :upload)
    File.copy!(up.path, upload_path(upload))
  end

  def upload_path(upload) do
    upload_path(upload.id, upload.name)
  end

  def upload_path(id, name) do
    dir = upload_dir(id)
    Path.join(dir, name)
  end

  # Would be nicer to pattern match %Upload{...}, but...
  def upload_dir(%{id: id}) do
    upload_dir(id)
  end

  def upload_dir(uuid) do
    pre = String.slice(uuid, 0, 2)
    dir = Path.join(upload_base(), "#{pre}/#{uuid}")
    File.mkdir_p!(dir)
    dir
  end

  def upload_base() do
    env = Application.get_env(:inkfish, :env)
    Path.expand("~/.local/data/inkfish/uploads/#{env}")
  end
end
