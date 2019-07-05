defmodule Inkfish.Subs.Sub do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subs" do
    field :active, :boolean, default: false
    field :score, :decimal
    field :assignment_id, :id
    belongs_to :reg, Inkfish.Users.Reg
    belongs_to :upload, Inkfish.Uploads.Upload, type: :binary_id
    has_many :grades, Inkfish.Grades.Grade

    timestamps()
  end

  @doc false
  def changeset(sub, attrs) do
    sub
    |> cast(attrs, [:active, :score])
    |> validate_required([:active, :score])
  end
end
