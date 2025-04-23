
defmodule TimeManagerAppWeb.TeamController do
  use TimeManagerAppWeb, :controller
  alias TimeManagerApp.Teams
  alias TimeManagerApp.Teams.Team
  alias TimeManagerApp.Accounts
  alias TimeManagerAppWeb.JSONHelper

  action_fallback(TimeManagerAppWeb.FallbackController)

  def index(conn, _params) do
    teams = Teams.list_teams()
    json(conn, %{data: Enum.map(teams, &JSONHelper.render_team_with_members/1)})
  end

  def create(conn, %{"team" => team_params}) do
    with {:ok, %Team{} = team} <- Teams.create_team(team_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/teams/#{team.id}")
      |> json(%{data: JSONHelper.render_item(team)})
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, id} <- parse_id(id),
      team when not is_nil(team) <- Teams.get_team(id) do
      json(conn, %{data: JSONHelper.render_team_with_members(team)})
    else
      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid ID format"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})
    end
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    with {:ok, id} <- parse_id(id),
        team when not is_nil(team) <- Teams.get_team(id),
        {:ok, %Team{} = updated_team} <- Teams.update_team(team, team_params) do
      json(conn, %{data: JSONHelper.render_item(updated_team)})
    else
      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid ID format"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: JSONHelper.render_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, id} <- parse_id(id),
        team when not is_nil(team) <- Teams.get_team(id),
        {:ok, %Team{}} <- Teams.delete_team(team) do
      send_resp(conn, :no_content, "")
    else
      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid ID format"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to delete team"})
    end
  end

  def add_user(conn, %{"team_id" => team_id, "user_id" => user_id}) do
    with {:ok, team_id} <- parse_id(team_id),
        {:ok, user_id} <- parse_id(user_id),
        team when not is_nil(team) <- Teams.get_team(team_id),
        user when not is_nil(user) <- Accounts.get_user(user_id),
        {:ok, %Team{} = updated_team} <- Teams.add_user_to_team(team, user) do
      json(conn, %{data: JSONHelper.render_item(updated_team)})
    else
      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid ID format"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team or User not found"})

      {:error, :user_already_in_team} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "User is already a member of this team"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: JSONHelper.render_errors(changeset)})
    end
  end

  def remove_user(conn, %{"team_id" => team_id, "user_id" => user_id}) do
    with {:ok, team_id} <- parse_id(team_id),
        {:ok, user_id} <- parse_id(user_id),
        team when not is_nil(team) <- Teams.get_team(team_id),
        user when not is_nil(user) <- Accounts.get_user(user_id),
        {:ok, %Team{} = updated_team} <- Teams.remove_user_from_team(team, user) do
      json(conn, %{data: JSONHelper.render_item(updated_team)})
    else
      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid ID format"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team or User not found"})

      {:error, :user_not_in_team} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "User is not a member of this team"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: JSONHelper.render_errors(changeset)})
    end
  end

  defp parse_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, ""} -> {:ok, int_id}
      _ -> {:error, :invalid_id}
    end
  end

  defp parse_id(id) when is_integer(id), do: {:ok, id}
  defp parse_id(_), do: {:error, :invalid_id}
end
