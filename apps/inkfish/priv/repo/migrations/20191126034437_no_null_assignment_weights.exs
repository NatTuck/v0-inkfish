defmodule Inkfish.Repo.Migrations.NoNullAssignmentWeights do
  use Ecto.Migration

  import Ecto.Query, only: [from: 2]
  alias Inkfish.Repo
  alias Inkfish.Assignments.Assignment

  def change do
    Repo.update_all(
      from(aa in Assignment, where: is_nil(aa.weight)),
      set: [weight: "1"]
    )

    alter table("assignments") do
      modify :weight, :decimal, from: :decimal, null: false, default: "1"
    end
  end
end
