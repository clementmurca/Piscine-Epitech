defmodule TimeManagerAppWeb.TeamClockController do
  use TimeManagerAppWeb, :controller
  alias TimeManagerApp.TimeTracking
  alias TimeManagerApp.TimeTracking.TeamClock
  alias TimeManagerAppWeb.JSONHelper

  action_fallback TimeManagerAppWeb.FallbackController

  #  Function to list all clocks for a team without params
  def index(conn, %{}) do
    current_user = conn.assigns.current_user
    if current_user.role in ["Admin", "manager", "general_manager","employee"] do
      clocks = TimeTracking.list_all_team_clocks()
      json(conn, %{data: JSONHelper.render_list(clocks)})
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end

  def index(conn, %{"teamID" => team_id}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_team_id} <- parse_id(team_id) do
      if current_user.role in ["Admin", "manager", "general_manager","employee"] || current_user.id == parsed_team_id do
        clocks = TimeTracking.list_team_clocks(parsed_team_id)
        json(conn, %{data: JSONHelper.render_list(clocks)})
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Access denied"})
      end
    end
  end

  def create(conn, %{"teamID" => team_id, "team_clock" => clock_params}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_team_id} <- parse_id(team_id) do
      if current_user.role in ["Admin", "manager", "general_manager"] do
        case TimeTracking.create_team_clock(parsed_team_id, clock_params) do
          {:ok, %TeamClock{} = clock} ->
            conn
            |> put_status(:created)
            |> json(%{
              data: JSONHelper.render_item(clock),
              links: %{
                self: ~p"/api/teams/#{team_id}/clocks/#{clock.id}"
              }
            })
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: JSONHelper.render_errors(changeset)})
        end
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Access denied"})
      end
    end
  end

  def show(conn, %{"teamID" => team_id, "id" => id}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_team_id} <- parse_id(team_id),
         {:ok, parsed_id} <- parse_id(id) do
      if current_user.role in ["Admin", "manager", "general_manager","employee"]  || current_user.id == parsed_team_id do
        case TimeTracking.get_team_clock!(parsed_id) do
          %TeamClock{} = clock ->
            json(conn, %{data: JSONHelper.render_item(clock)})
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Clock not found"})
        end
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Access denied"})
      end
    end
  end


  defp parse_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, _} -> {:ok, int_id}
      :error -> {:error, :invalid_id}
    end
  end
  defp parse_id(id) when is_integer(id), do: {:ok, id}
  defp parse_id(_), do: {:error, :invalid_id}
end
