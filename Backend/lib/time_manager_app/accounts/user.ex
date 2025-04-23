defmodule TimeManagerApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Pbkdf2

  @derive {Jason.Encoder, only: [:id, :username, :email, :inserted_at, :updated_at]}
  schema "users" do
    field :username, :string
    field :email, :string
    field :role, :string, default: "employee"
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :clocks, TimeManagerApp.TimeTracking.Clock, on_delete: :delete_all
    has_many :working_times, TimeManagerApp.TimeTracking.WorkingTime, on_delete: :delete_all
    # belongs_to :managed_team, TimeManagerApp.Teams.Team, foreign_key: :managed_team_id
    many_to_many :teams, TimeManagerApp.Teams.Team, join_through: "users_teams", on_replace: :delete


    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :role])
    |> validate_required([:username, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_inclusion(:role, ["employee", "manager", "general_manager", "Admin"], message: "is not a valid role please choose one of the following option : employee / manager / general manager / admin")
    |> validate_length(:password, min: 3)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        changeset
        |> put_change(:password_hash, Pbkdf2.hash_pwd_salt(password))
        |> put_change(:password, nil)
    end
  end

end
