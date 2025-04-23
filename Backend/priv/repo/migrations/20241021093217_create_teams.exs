defmodule TimeManagerApp.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false
      add :manager_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:teams, [:name])
  end
end
