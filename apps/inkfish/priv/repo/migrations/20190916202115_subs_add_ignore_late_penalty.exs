defmodule Inkfish.Repo.Migrations.SubsAddIgnoreLatePenalty do
  use Ecto.Migration

  def change do
    alter table(:subs) do
      add :ignore_late_penalty, :boolean, null: false, default: false
    end
  end
end
