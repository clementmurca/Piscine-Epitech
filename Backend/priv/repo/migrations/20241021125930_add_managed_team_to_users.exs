defmodule TimeManagerApp.Repo.Migrations.AddManagedTeamToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :managed_team_id, references(:teams)
    end
  end
end
