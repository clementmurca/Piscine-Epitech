defmodule TimeManagerApp.Teams do
  import Ecto.Query, warn: false
  alias TimeManagerApp.Repo
  alias TimeManagerApp.Teams.Team
  alias TimeManagerApp.Accounts.User

  def list_teams do
    Repo.all(Team)
    |> Repo.preload(:members)
    |> Repo.preload(:manager)
  end

  def get_team(id) do
    Team
    |> Repo.get(id)
    |> Repo.preload(:members)
    |> Repo.preload(:manager)
  end

  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  def add_user_to_team(%Team{} = team, %User{} = user) do
    team = Repo.preload(team, :members)
    if Enum.any?(team.members, fn member -> member.id == user.id end) do
      {:error, :user_already_in_team}
    else
      team
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:members, [user | team.members])
      |> Repo.update()
    end
  end
  def remove_user_from_team(%Team{} = team, %User{} = user) do
    team = Repo.preload(team, :members)

    if Enum.any?(team.members, fn member -> member.id == user.id end) do
      updated_members = Enum.filter(team.members, &(&1.id != user.id))

      team
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.cast_assoc(:members, with: fn _, _ ->
        Ecto.Changeset.change(%TimeManagerApp.Accounts.User{})
      end)
      |> Ecto.Changeset.put_assoc(:members, updated_members)
      |> Repo.update()
    else
      {:error, :user_not_in_team}
    end
  end
end
