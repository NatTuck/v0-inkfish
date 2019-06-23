defmodule Inkfish.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :login, :string, null: false
      add :email, :string, null: false
      add :given_name, :string, null: false
      add :surname, :string, null: false 
      add :nickname, :string, null: false, default: ""
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

    create index(:users, [:login], unique: true)
    create index(:users, [:email], unique: true)
  end
end
