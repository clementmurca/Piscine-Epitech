defmodule TimeManagerAppWeb.HomeController do
  use TimeManagerAppWeb, :controller

  def index(conn, _params) do
    text(conn, "Welcome to our Time Manager App - #{Mix.env()}")
  end
end