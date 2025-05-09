defmodule TimeManagerAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :time_manager_app


  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_time_manager_app_key",
    signing_salt: "gt2q4Q25",
    same_site: "Lax"
  ]

  # socket "/live", Phoenix.LiveView.Socket,
  #   websocket: [connect_info: [session: @session_options]],
  #   longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :time_manager_app,
    gzip: false,
    only: TimeManagerAppWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :time_manager_app
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  
  plug Corsica,
  origins: ["http://localhost:5173", "http://localhost:8080"],
  allow_headers: ["Content-Type", "Authorization", "X-XSRF-TOKEN"],
  allow_credentials: true,
  allow_methods: ["GET", "POST", "PUT", "PATCH", "DELETE"]
  plug TimeManagerAppWeb.Router
end
