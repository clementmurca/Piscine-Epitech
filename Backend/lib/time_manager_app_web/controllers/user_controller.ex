defmodule TimeManagerAppWeb.UserController do
  use TimeManagerAppWeb, :controller
  alias TimeManagerApp.Accounts
  alias TimeManagerApp.Accounts.User
  alias TimeManagerAppWeb.JSONHelper
  alias TimeManagerApp.Token.JwtAuthToken

  action_fallback(TimeManagerAppWeb.FallbackController)

  def translate_error({msg, opts}) do
  # Ecto's default error message handling
  Enum.reduce(opts, msg, fn {key, value}, acc ->
    String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
  end)
end


  def index(conn, params) do
    current_user = conn.assigns.current_user

    if current_user.role in ["Admin", "manager", "general_manager", "employee"] do
      users =
        case params do
          %{"email" => email, "username" => username} ->
            Accounts.get_users_by_email_and_username(email, username)

          _ ->
            Accounts.list_users()
        end

      json(conn, %{data: JSONHelper.render_list(users)})
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    with {:ok, user_id} <- parse_id(id),
         user <- Accounts.get_user!(user_id) do
      if current_user.role in ["Admin", "manager", "general_manager",   "employee"] ||
           current_user.id == user_id do
        json(conn, %{data: JSONHelper.render_item(user)})
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Access denied"})
      end
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> json(%{data: JSONHelper.render_item(user)})
    end
  end

 def update(conn, %{"id" => id, "user" => user_params}) do
  current_user = conn.assigns.current_user

  with {:ok, user_id} <- parse_id(id),
       user <- Accounts.get_user!(user_id) do
    if current_user.role in ["Admin", "manager", "general_manager", "employee"] ||
         current_user.id == user_id do
      case Accounts.update_user(user, user_params) do
        {:ok, %User{} = updated_user} ->
          json(conn, %{data: JSONHelper.render_item(updated_user)})

        {:error, changeset} ->
          # Correctly handle changeset errors using `traverse_errors/2`
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
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

    with {:ok, user_id} <- parse_id(id),
         user <- Accounts.get_user!(user_id) do
      if current_user.role in ["Admin", "general_manager"] do
        case Accounts.delete_user(user) do
          {:ok, %User{}} ->
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

  def login(conn, %{"username" => username, "password" => password}) do
    case Accounts.authenticate_user(username, password) do
      {:ok, user} ->
        token =
          JwtAuthToken.generate_token(%{
            "user_id" => user.id,
            "role" => user.role
          })

        IO.inspect(token, label: "Generated Token")

        peek_result = Joken.peek_claims(token)
        IO.inspect(peek_result, label: "Peek Claims Result")


        {:ok, claims} = Joken.peek_claims(token)
        xsrf_token = claims["xsrf"]

        conn
        |> put_resp_cookie("jwt", token, http_only: true, secure: true, max_age: 30 * 24 * 60 * 60)
        |> json(%{
          message: "Login successful",
          user: %{id: user.id, username: user.username, email: user.email, role: user.role},
          xsrf_token: xsrf_token
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid username or password"})
    end
  end

def delete_own_account(conn, _params) do
  current_user = conn.assigns.current_user

  # Fetch the actual user struct from the database
  user = Accounts.get_user!(current_user.id)

  case Accounts.delete_user(user) do
    {:ok, %User{}} ->
      send_resp(conn, :no_content, "")

    {:error, changeset} ->
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{errors: changeset})
  end
end




  def logout(conn, _params) do
    conn
    |> delete_resp_cookie("jwt")
    |> put_status(:ok)
    |> json(%{message: "Logout successful"})
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
