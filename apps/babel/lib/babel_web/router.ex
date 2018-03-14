defmodule BabelWeb.Router do
  use BabelWeb, :router
  use Plug.ErrorHandler

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BabelWeb.Auth, repo: Babel.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BabelWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    resources "/rooms", RoomController
  end

  # Other scopes may use custom stacks.
  # scope "/api", BabelWeb do
  #   pipe_through :api
  # end
  def handle_errors(conn, %{kind: _kind, reason: reason, stack: stack}) do
    Bugsnag.report(reason, stacktrace: stack)
  end
end
