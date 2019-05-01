defmodule Inkfish.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

  end
end
