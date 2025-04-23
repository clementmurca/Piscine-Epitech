defmodule TimeManagerApp.TimeTracking.Clock do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :time, :status, :user_id, :inserted_at, :updated_at]}
  schema "clocks" do
    field :time, :utc_datetime
    field :status, :boolean
    belongs_to :user, TimeManagerApp.Accounts.User

    timestamps()
  end

  def changeset(clock, attrs) do
    clock
    |> cast(attrs, [:time, :status, :user_id])
    |> validate_required([:time, :status, :user_id])
  end
end
