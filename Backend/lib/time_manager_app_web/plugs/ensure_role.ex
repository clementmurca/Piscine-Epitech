defmodule TimeManagerAppWeb.Plugs.EnsureRole do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(roles), do: roles

  def call(conn, roles) do
    current_user = conn.assigns[:current_user]

    # Check if the current user's role is in the allowed roles
    if current_user && current_user.role in roles do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
      |> halt()
    end
  end
end
