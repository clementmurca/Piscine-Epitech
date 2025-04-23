defmodule TimeManagerApp.Repo.Migrations.CreateTeamClocks do
  use Ecto.Migration

  def change do
    create table(:team_clocks) do
      add :time, :utc_datetime, null: false
      add :status, :boolean, default: true, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:team_clocks, [:team_id])
  end
end
