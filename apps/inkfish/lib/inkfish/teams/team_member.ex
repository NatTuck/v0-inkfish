defmodule Inkfish.Teams.TeamMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_members" do
    field :active, :boolean, default: false
    field :team_id, :id
    field :reg_id, :id

    timestamps()
  end

  @doc false
  def changeset(team_member, attrs) do
    team_member
    |> cast(attrs, [:active])
    |> validate_required([:active])
  end
end
