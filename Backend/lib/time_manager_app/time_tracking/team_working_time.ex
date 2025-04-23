defmodule TimeManagerApp.TimeTracking.TeamWorkingTime do
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_working_times" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    belongs_to :team, TimeManagerApp.Teams.Team

    timestamps()
  end

  def changeset(team_working_time, attrs) do
    team_working_time
    |> cast(attrs, [:start, :end, :team_id])
    |> validate_required([:start, :end, :team_id])
    |> foreign_key_constraint(:team_id)
    |> validate_start_end_time()
  end

  defp validate_start_end_time(changeset) do
    case {get_field(changeset, :start), get_field(changeset, :end)} do
      {start, end_time} when not is_nil(start) and not is_nil(end_time) ->
        if DateTime.compare(end_time, start) == :gt do
          changeset
        else
          add_error(changeset, :end, "must be after start time")
        end
      _ ->
        changeset
    end
  end
end
