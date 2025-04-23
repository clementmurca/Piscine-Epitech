defmodule TimeManagerAppWeb.WorkingTimeController do
  use TimeManagerAppWeb, :controller
  alias TimeManagerApp.TimeTracking
  alias TimeManagerApp.TimeTracking.WorkingTime
  alias TimeManagerAppWeb.JSONHelper

  action_fallback TimeManagerAppWeb.FallbackController

  def index(conn, %{"userID" => user_id, "start" => start, "end" => end_date}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_user_id} <- parse_id(user_id),
         {:ok, parsed_start} <- parse_datetime(start),
         {:ok, parsed_end} <- parse_datetime(end_date) do
      if current_user.role in ["Admin", "manager", "general_manager", "employee"] || current_user.id == parsed_user_id do
        working_times = TimeTracking.list_working_times(parsed_user_id, parsed_start, parsed_end)
        json(conn, %{data: JSONHelper.render_list(working_times)})
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Access denied"})
      end
    end
  end

  def index(conn, params) do
    current_user = conn.assigns.current_user
    case params do
      %{"userID" => user_id, "start" => start, "end" => end_date} ->
        with {:ok, parsed_user_id} <- parse_id(user_id),
             {:ok, parsed_start} <- parse_datetime(start),
             {:ok, parsed_end} <- parse_datetime(end_date) do
          if current_user.role in ["Admin", "manager", "general_manager", "employee"] || current_user.id == parsed_user_id do
            working_times = TimeTracking.list_working_times(parsed_user_id, parsed_start, parsed_end)
            json(conn, %{data: JSONHelper.render_list(working_times)})
          else
            conn
            |> put_status(:forbidden)
            |> json(%{error: "Access denied"})
          end
        end
      _ ->
        if current_user.role in ["Admin", "manager", "general_manager", "employee"] do
          working_times = TimeTracking.list_all_working_times()
          json(conn, %{data: JSONHelper.render_list(working_times)})
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Access denied"})
        end
    end
  end

  def show(conn, %{"userID" => user_id, "id" => id}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_user_id} <- parse_id(user_id),
         {:ok, parsed_id} <- parse_id(id),
         working_time <- TimeTracking.get_working_time!(parsed_id, parsed_user_id) do
      if current_user.role in ["Admin", "manager", "general_manager", "employee"] || current_user.id == parsed_user_id do
        json(conn, %{data: JSONHelper.render_item(working_time)})
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Access denied"})
      end
    end
  end

  def create(conn, %{"userID" => user_id, "working_time" => working_time_params}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_user_id} <- parse_id(user_id) do
      if current_user.role in ["Admin", "manager", "general_manager", "employee"] || current_user.id == parsed_user_id do
        case TimeTracking.create_working_time(parsed_user_id, working_time_params) do
          {:ok, %WorkingTime{} = working_time} ->
            conn
            |> put_status(:created)
            |> put_resp_header("location", ~p"/api/workingtime/#{working_time.id}")
            |> json(%{data: JSONHelper.render_item(working_time)})
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

  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_id} <- parse_id(id),
         working_time <- TimeTracking.get_working_time!(parsed_id) do
      if current_user.role in ["Admin", "manager", "general_manager", "employee" ] || current_user.id == working_time.user_id do
        case TimeTracking.update_working_time(working_time, working_time_params) do
          {:ok, %WorkingTime{} = updated_working_time} ->
            json(conn, %{data: JSONHelper.render_item(updated_working_time)})
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

  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    with {:ok, parsed_id} <- parse_id(id),
         working_time <- TimeTracking.get_working_time!(parsed_id) do
      if current_user.role == "Admin" do
        case TimeTracking.delete_working_time(working_time) do
          {:ok, %WorkingTime{}} ->
            send_resp(conn, :no_content, "")
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

  defp parse_datetime(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _} -> {:ok, datetime}
      {:error, _} -> {:error, :invalid_datetime}
    end
  end

#afficher la liste des working times pour un user précis
def list_wt_user(conn, %{"userID" => user_id}) do
  IO.inspect(conn.assigns.current_user, label: "Current User")
  IO.inspect(%{"userID" => user_id}, label: "Params Received")

  current_user = conn.assigns.current_user
  with {:ok, parsed_user_id} <- parse_id(user_id) do
    IO.inspect({parsed_user_id}, label: "Parsed Params")

    if current_user.role in ["admin", "manager", "general_manager", "employee"] || current_user.id == parsed_user_id do
      working_times = TimeTracking.list_working_times_user(parsed_user_id)
      json(conn, %{data: JSONHelper.render_list(working_times)})
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end
end
end
