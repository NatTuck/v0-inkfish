defmodule Inkfish.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :login, :string
    field :email, :string
    field :given_name, :string
    field :surname, :string
    field :nickname, :string, default: ""
    field :is_admin, :boolean, default: false
    belongs_to :photo_upload, Inkfish.Uploads.Upload, type: :binary_id
    has_many :regs, Inkfish.Users.Reg

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:login, :email, :given_name, :surname,
                   :nickname, :is_admin, :photo_upload_id])
    |> validate_required([:login, :email, :given_name, :surname])
    |> unique_constraint(:login)
    |> unique_constraint(:email)
    |> validate_length(:login, min: 2)
    |> validate_format(:email, ~r/@.*\./)
    |> validate_length(:given_name, min: 1)
    |> validate_length(:surname, min: 1)
  end
end
