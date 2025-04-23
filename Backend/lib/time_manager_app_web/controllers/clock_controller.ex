defmodule TimeManagerAppWeb.ClockController do
  use TimeManagerAppWeb, :controller
  alias TimeManagerApp.TimeTracking
  alias TimeManagerApp.TimeTracking.Clock
  alias TimeManagerAppWeb.JSONHelper

  action_fallback TimeManagerAppWeb.FallbackController

  def index(conn, params) do
    current_user = conn.assigns.current_user
    case params do
      %{"userID" => user_id} ->
        with {:ok, parsed_user_id} <- parse_id(user_id) do
          if current_user.role in ["Admin", "manager", "general_manager", "employee"] || current_user.id == parsed_user_id do
            clocks = TimeTracking.list_clocks(parsed_user_id)
            json(conn, %{data: JSONHelper.render_list(clocks)})
          else
            conn
            |> put_status(:forbidden)
            |> json(%{error: "Access denied"})
          end
        end
      _ ->
        if current_user.role in ["Admin", "manager", "general_manager", "employee"] do
          clocks = TimeTracking.list_all_clocks()
          json(conn, %{data: JSONHelper.render_list(clocks)})
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Access denied"})
        end
    end
  end

  def create(conn, %{"userID" => user_id, "clock" => clock_params}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_user_id} <- parse_id(user_id) do
      if current_user.role == "Admin" || current_user.id == parsed_user_id do
        case TimeTracking.create_clock(parsed_user_id, clock_params) do
          {:ok, %Clock{} = clock} ->
            conn
            |> put_status(:created)
            |> put_resp_header("location", ~p"/api/clocks/#{clock.id}")
            |> json(%{data: JSONHelper.render_item(clock)})
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: changeset})
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
