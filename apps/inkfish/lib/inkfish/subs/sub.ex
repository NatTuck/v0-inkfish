defmodule Inkfish.Subs.Sub do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [autogenerate: {Inkfish.LocalTime, :now, []}]

  schema "subs" do
    field :active, :boolean, default: false
    field :score, :decimal
    field :hours_spent, :decimal, default: Decimal.new("1.0")
    field :note, :string
    belongs_to :assignment, Inkfish.Assignments.Assignment
    belongs_to :reg, Inkfish.Users.Reg
    belongs_to :team, Inkfish.Teams.Team
    belongs_to :upload, Inkfish.Uploads.Upload, type: :binary_id
    has_many :grades, Inkfish.Grades.Grade

    field :updated_score, :decimal, virtual: true

    timestamps()
  end

  @doc false
  def changeset(sub, attrs) do
    sub
    |> cast(attrs, [:assignment_id, :reg_id, :team_id, :upload_id, :hours_spent, :note])
    |> validate_required([:assignment_id, :reg_id, :team_id, :upload_id, :hours_spent])
  end

  def make_active(sub) do
    cast(sub, %{active: true}, [:active])
  end
end
