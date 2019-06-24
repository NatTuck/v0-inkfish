defmodule Inkfish.Subs.Sub do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subs" do
    field :active, :boolean, default: false
    field :score, :decimal
    field :assignment_id, :id
    field :reg_id, :id
    field :upload_id, :id

    timestamps()
  end

  @doc false
  def changeset(sub, attrs) do
    sub
    |> cast(attrs, [:active, :score])
    |> validate_required([:active, :score])
  end
end
