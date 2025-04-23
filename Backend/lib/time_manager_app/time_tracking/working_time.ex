defmodule TimeManagerApp.TimeTracking.WorkingTime do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :start, :end, :user_id, :inserted_at, :updated_at]}
  schema "working_times" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    belongs_to :user, TimeManagerApp.Accounts.User

    timestamps()
  end

  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [:start, :end, :user_id])
    |> validate_required([:start, :end, :user_id])
    |> validate_start_end_order()
  end

  defp validate_start_end_order(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{start: start, end: end_time}} ->
        if DateTime.compare(start, end_time) == :gt do
          add_error(changeset, :end, "must be after start time")
        else
          changeset
        end
      _ ->
        changeset
    end
  end
end
