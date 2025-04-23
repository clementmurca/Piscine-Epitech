defmodule TimeManagerApp.Token.JwtAuthToken do
  use Joken.Config

  @impl true
  def token_config do
    thirty_days_in_seconds = 30 * 24 * 60 * 60 # 30 jours en secondes

    default_claims(default_exp: thirty_days_in_seconds)
    |> add_claim("xsrf", fn -> Ecto.UUID.generate() end, &(&1 != nil))
    |> add_claim("user_id", nil, &(&1 != nil))
    |> add_claim("role", nil, &(&1 != nil))
  end

  def generate_token(extra_claims) do
    {:ok, claims} = token_config()
    |> Joken.generate_claims(extra_claims)

    generate_and_sign!(claims)
  end

  def verify_token(token) do
    case verify_and_validate(token) do
      {:ok, claims} -> {:ok, claims}
      {:error, reason} -> {:error, reason}
    end
  end
end
