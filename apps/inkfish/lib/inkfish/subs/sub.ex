defmodule Inkfish.Subs.Sub do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [autogenerate: {Inkfish.LocalTime, :now, []}]

  schema "subs" do
    field :active, :boolean, default: false
    field :late_penalty, :decimal
    field :score, :decimal
    field :hours_spent, :decimal, default: Decimal.new("1.0")
    field :note, :string
    field :ignore_late_penalty, :boolean, default: false
    belongs_to :assignment, Inkfish.Assignments.Assignment
    belongs_to :reg, Inkfish.Users.Reg
    belongs_to :team, Inkfish.Teams.Team
    belongs_to :upload, Inkfish.Uploads.Upload, type: :binary_id
    has_many :grades, Inkfish.Grades.Grade

    timestamps()
  end

  @doc false
  def changeset(sub, attrs) do
    sub
    |> cast(attrs, [:assignment_id, :reg_id, :team_id, :upload_id, :hours_spent, :note])
    |> validate_required([:assignment_id, :reg_id, :team_id, :upload_id, :hours_spent])
    |> foreign_key_constraint(:upload_id)
  end

  def make_active(sub) do
    cast(sub, %{active: true}, [:active])
  end

  def change_ignore_late(sub, attrs) do
    sub
    |> cast(attrs, [:ignore_late_penalty])
    |> validate_required([:ignore_late_penalty])
  end

  def to_map(sub) do
    grades = Enum.map sub.grades, fn gr ->
      Inkfish.Grades.Grade.to_map(gr)
    end
    sub = Map.drop(sub, [:__struct__, :__meta__, :assignment, :reg, :team, :upload])
    %{ sub | grades: grades }
  end
end
