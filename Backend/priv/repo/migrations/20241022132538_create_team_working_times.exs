defmodule TimeManagerApp.Repo.Migrations.CreateTeamWorkingTimes do
  use Ecto.Migration

  def change do
    create table(:team_working_times) do
      add :start, :utc_datetime, null: false
      add :end, :utc_datetime, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:team_working_times, [:team_id])
  end
end
