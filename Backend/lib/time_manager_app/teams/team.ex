defmodule TimeManagerApp.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :manager_id, :inserted_at, :updated_at]}
  schema "teams" do
    field :name, :string
    belongs_to :manager, TimeManagerApp.Accounts.User
    many_to_many :members, TimeManagerApp.Accounts.User, join_through: "users_teams",  on_replace: :delete

    timestamps()
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :manager_id])
    |> validate_required([:name])
    |> cast_assoc(:members, with: &TimeManagerApp.Accounts.User.changeset/2)
  end
end
