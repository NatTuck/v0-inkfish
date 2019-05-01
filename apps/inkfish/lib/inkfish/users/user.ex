defmodule Inkfish.Users.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :email, :string
    field :is_admin, :boolean, default: false
    has_many :regs, Inkfish.Users.Reg

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :is_admin])
    |> validate_required([:email, :is_admin])
  end
end
