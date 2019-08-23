defmodule Inkfish.Repo.Migrations.CreateLineComments do
  use Ecto.Migration

  def change do
    create table(:line_comments) do
      add :path, :string, null: false
      add :line, :integer, null: false
      add :points, :decimal, null: false
      add :text, :text, null: false, default: ""
      add :grade_id, references(:grades, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :restrict), null: false

      timestamps()
    end

    create index(:line_comments, [:grade_id])
    create index(:line_comments, [:user_id])
  end
end
