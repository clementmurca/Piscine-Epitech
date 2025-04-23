defmodule TimeManagerAppWeb.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller
  alias TimeManagerApp.Token.JwtAuthToken

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_cookies(conn)
    IO.inspect(conn.cookies, label: "Cookies in AuthPlug")
    with {:ok, token} <- get_token(conn),
         {:ok, claims} <- JwtAuthToken.verify_token(token),
         :ok <- verify_xsrf(conn, claims) do
          IO.inspect(claims, label: "Verified Claims")
      assign(conn, :current_user, %{id: claims["user_id"], role: claims["role"]})
    else
      {:error, reason} ->
        IO.inspect(reason, label: "Token verification error")
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized", reason: inspect(reason)})
        |> halt()
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        |> halt()
    end
  end

  defp get_token(conn) do
    case conn.cookies["jwt"] do
      nil -> {:error, :missing_token}
      token -> {:ok, token}
    end
  end

  defp verify_xsrf(conn, claims) do
    xsrf_token = claims["xsrf"]

    case get_req_header(conn, "x-xsrf-token") do
      [header_token] ->
        if header_token == xsrf_token, do: :ok, else: {:error, :invalid_xsrf}
      _ ->
        {:error, :missing_xsrf}
    end
  end
end
