defmodule Inkfish.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [autogenerate: {Inkfish.LocalTime, :now, []}]

  schema "teams" do
    field :active, :boolean, default: false

    belongs_to :teamset, Inkfish.Teams.Teamset
    has_many :subs, Inkfish.Subs.Sub
    has_many :team_members, Inkfish.Teams.TeamMember
    many_to_many :regs, Inkfish.Users.Reg,
      join_through: Inkfish.Teams.TeamMember, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    cset = team
    |> cast(attrs, [:teamset_id, :active])
    |> validate_required([:teamset_id])
    |> foreign_key_constraint(:teamset_id)

    if attrs["regs"] || attrs[:regs] do
      regs = Enum.map (attrs["regs"] || attrs[:regs]), fn (reg) ->
        Inkfish.Users.Reg.changeset(reg, %{})
      end
      if length(regs) > 0 do
        put_assoc(cset, :regs, regs)
      else
        add_error(cset, :regs, "Teams must have members.")
      end
    else
      cset
    end
  end
end
