defmodule InkfishWeb.Router do
  use InkfishWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InkfishWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController
    resources "/courses", CourseController
    resources "/regs", RegController
    resources "/buckets", BucketController


  end

  # Other scopes may use custom stacks.
  # scope "/api", InkfishWeb do
  #   pipe_through :api
  # end
end
