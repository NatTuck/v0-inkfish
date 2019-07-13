defmodule Inkfish.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :teamset_id, :id

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [])
    |> validate_required([])
  end
end