defmodule TimeManagerApp.TimeTracking.TeamClock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_clocks" do
    field :time, :utc_datetime
    field :status, :boolean, default: true  # true for clock in, false for clock out
    belongs_to :team, TimeManagerApp.Teams.Team

    timestamps()
  end

  def changeset(team_clock, attrs) do
    team_clock
    |> cast(attrs, [:time, :status, :team_id])
    |> validate_required([:time, :status, :team_id])
    |> foreign_key_constraint(:team_id)
  end
end
