defmodule TimeManagerAppWeb.TeamWorkingTimeController do
  use TimeManagerAppWeb, :controller
  alias TimeManagerApp.TimeTracking
  alias TimeManagerApp.TimeTracking.TeamWorkingTime
  alias TimeManagerAppWeb.JSONHelper

  action_fallback TimeManagerAppWeb.FallbackController

  # Function to list all working times for a team without params start and end
  def index(conn, %{}) do
    current_user = conn.assigns.current_user
    if current_user.role in ["Admin", "manager", "general_manager"] do
      working_times = TimeTracking.list_all_team_working_times()
      json(conn, %{data: JSONHelper.render_list(working_times)})
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end

  def index(conn, %{"teamID" => team_id, "start" => start, "end" => end_date}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_team_id} <- parse_id(team_id),
         {:ok, parsed_start} <- parse_datetime(start),
         {:ok, parsed_end} <- parse_datetime(end_date) do
          if current_user.role in ["Admin", "manager", "general_manager"] || current_user.id == parsed_team_id do
        working_times = TimeTracking.list_team_working_times(parsed_team_id, parsed_start, parsed_end)
        json(conn, %{data: JSONHelper.render_list(working_times)})
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Access denied"})
      end
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_id} <- parse_id(id),
         working_time <- TimeTracking.get_team_working_time!(parsed_id) do
      if current_user.role in ["Admin", "manager", "general_manager"] do
        json(conn, %{data: JSONHelper.render_item(working_time)})
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Access denied"})
      end
    end
  end

  def create(conn, %{"teamID" => team_id, "team_working_time" => params}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_team_id} <- parse_id(team_id) do
      if current_user.role in ["Admin", "general_manager", "manager"] do
        case TimeTracking.create_team_working_time(parsed_team_id, params) do
          {:ok, %TeamWorkingTime{} = working_time} ->
            conn
            |> put_status(:created)
            |> put_resp_header("location", ~p"/api/teams/#{team_id}/working_times/#{working_time.id}")
            |> json(%{data: JSONHelper.render_item(working_time)})
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

  def update(conn, %{"teamID" => _team_id, "id" => id, "team_working_time" => params}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_id} <- parse_id(id),
         working_time <- TimeTracking.get_team_working_time!(parsed_id) do
          if current_user.role in ["Admin", "general_manager", "manager"] do
        case TimeTracking.update_team_working_time(working_time, params) do
          {:ok, %TeamWorkingTime{} = updated_working_time} ->
            json(conn, %{data: JSONHelper.render_item(updated_working_time)})
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

  def delete(conn, %{"teamID" => _team_id, "id" => id}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_id} <- parse_id(id),
         working_time <- TimeTracking.get_team_working_time!(parsed_id) do
          if current_user.role in ["Admin", "general_manager", "manager"] do
        case TimeTracking.delete_team_working_time(working_time) do
          {:ok, %TeamWorkingTime{}} ->
            send_resp(conn, :no_content, "")
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

  defp parse_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, _} -> {:ok, int_id}
      :error -> {:error, :invalid_id}
    end
  end
  defp parse_id(id) when is_integer(id), do: {:ok, id}
  defp parse_id(_), do: {:error, :invalid_id}

  defp parse_datetime(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _} -> {:ok, datetime}
      {:error, _} -> {:error, :invalid_datetime}
    end
  end
end
