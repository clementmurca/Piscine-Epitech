defmodule TimeManagerAppWeb.FallbackController do
  use TimeManagerAppWeb, :controller
  alias TimeManagerAppWeb.JSONHelper

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Invalid ID format"})
    |> json(%{errors: JSONHelper.render_errors(changeset)})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Not Found"})
  end
end
