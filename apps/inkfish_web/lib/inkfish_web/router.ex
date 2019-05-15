defmodule InkfishWeb.Router do
  use InkfishWeb, :router
  
  alias InkfishWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Plugs.FetchUser
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plugs.Breadcrumb, {"Home", :page, :index}
  end
  
  pipeline :admin do
    plug Plugs.RequireUser, admin: true
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InkfishWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/dashboard", PageController, :dashboard
    resources "/session", SessionController, only: [:create, :delete], singleton: true
    resources "/users", UserController
    resources "/courses", CourseController do
      resources "/regs", RegController, only: [:index, :new, :create]
      resources "/buckets", BucketController, only: [:index, :new, :create]
    end
    resources "/regs", RegController, except: [:index, :new, :create]
    resources "/buckets", BucketController, except: [:index, :new, :create]
  end
  
  scope "/admin", InkfishWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]
    
    resources "/users", UserController
    resources "/courses", CourseController
  end


  # Other scopes may use custom stacks.
  # scope "/api", InkfishWeb do
  #   pipe_through :api
  # end
end

