defmodule Inkfish.Repo.Migrations.AddLatePenaltyField do
  use Ecto.Migration

  def change do
    alter table("subs") do
      add :late_penalty, :decimal
    end
  end
end
