defmodule TimeManagerApp.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # Conditionally add the column if it doesn't exist
      add_if_not_exists(:role, :string, default: "employee")
    end
  end
end
