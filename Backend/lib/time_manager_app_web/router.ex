defmodule TimeManagerAppWeb.Router do
  use TimeManagerAppWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_auth do
    plug(:accepts, ["json"])
    plug(TimeManagerAppWeb.Plugs.AuthPlug)
  end

  # Public routes
  scope "/api", TimeManagerAppWeb do
    pipe_through(:api)

    # Default route
    get("/", HomeController, :index)

    # Route for login
    post("/login", UserController, :login)

    # Route for logout
    post("/logout", UserController, :logout)

    # Route for users creation (registration)
    post("/users", UserController, :create)
  end

  # Protected routes
  scope "/api", TimeManagerAppWeb do
    pipe_through([:api, :api_auth])

    # Routes for users
    get("/users", UserController, :index)
    get("/users/:id", UserController, :show)
    put("/users/:id", UserController, :update)
    delete("/users/:id", UserController, :delete)
    delete("/profile", UserController, :delete_own_account)

    # Routes for working times
    get "/workingtime", WorkingTimeController, :index
    get "/workingtime/:userID", WorkingTimeController, :index
    get "/workingtimes/:userID", WorkingTimeController, :list_wt_user
    get "/workingtime/:userID/:id", WorkingTimeController, :show
    post "/workingtime/:userID", WorkingTimeController, :create
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :delete

    # Routes for clocks
    get("/clocks", ClockController, :index)
    get("/clocks/:userID", ClockController, :index)
    post("/clocks/:userID", ClockController, :create)

    # Routes for team working times
    get("/teams/working_times", TeamWorkingTimeController, :index)
    get("/teams/working_times/:id", TeamWorkingTimeController, :show)
    get("/teams/:teamID/working_times", TeamWorkingTimeController, :index)
    post("/teams/:teamID/working_times", TeamWorkingTimeController, :create)
    put("/teams/:teamID/working_times/:id", TeamWorkingTimeController, :update)
    delete("/teams/:teamID/working_times/:id", TeamWorkingTimeController, :delete)

    # Routes for team clocks
    get("/teams/clocks", TeamClockController, :index)
    get("/teams/:teamID/clocks", TeamClockController, :index)
    get("/teams/:teamID/clocks/:id", TeamClockController, :show)
    post("/teams/:teamID/clocks", TeamClockController, :create)

    # Routes for teams
    get("/teams", TeamController, :index)
    get("/teams/:id", TeamController, :show)
    post("/teams", TeamController, :create)
    put("/teams/:id", TeamController, :update)
    delete("/teams/:id", TeamController, :delete)
    post("/teams/:team_id/add_user/:user_id", TeamController, :add_user)
    delete("/teams/:team_id/remove_user/:user_id", TeamController, :remove_user)
  end
end
