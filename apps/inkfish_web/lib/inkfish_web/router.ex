defmodule InkfishWeb.Router do
  use InkfishWeb, :router
  
  alias InkfishWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug Plugs.Assign, client_mode: :browser
    plug :fetch_session
    plug Plugs.FetchUser
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plugs.Breadcrumb, {"Home", :page, :index}
  end

  pipeline :ajax do
    plug :accepts, ["json"]
    plug Plugs.Assign, client_mode: :ajax
    plug :fetch_session
    plug Plugs.FetchUser
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  
  pipeline :admin do
    plug Plugs.RequireUser, is_admin: true
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
    resources "/uploads", UploadController, only: [:create, :show]
    get "/uploads/:id/thumb", UploadController, :thumb
    resources "/courses", CourseController, only: [:index, :show] do
      resources "/regs", RegController, only: [:index, :new, :create]
      resources "/teams", TeamController, only: [:index, :new, :create]
      resources "/buckets", BucketController, only: [:index, :new, :create]
    end
    resources "/regs", RegController, except: [:index, :new, :create]
    resources "/teams", TeamController, except: [:index, :new, :create]
    resources "/assignments", AssignmentController, only: [:show]
    resources "/grades", GradeController, only: [:show]
  end

  scope "/staff", InkfishWeb.Staff, as: :staff do
    pipe_through :browser

    resources "/courses", CourseController do
      resources "/regs", RegController, only: [:index, :new, :create]
      resources "/teamsets", TeamsetController, only: [:index, :new, :create]
      resources "/buckets", BucketController, only: [:index, :new, :create]
    end
    resources "/regs", RegController, except: [:index, :new, :create]
    resources "/teamsets", TeamsetController, except: [:index, :new, :create] do
      resources "/teams", TeamController, only: [:index, :new, :create]
    end
    resources "/teams", TeamController, except: [:index, :new, :create]
    resources "/buckets", BucketController, except: [:index, :new, :create] do
      resources "/assignments", AssignmentController, only: [:index, :new, :create]
    end
    resources "/assignments", AssignmentController, except: [:index, :new, :create] do
      resources "/graders", GraderController, only: [:index, :new, :create]
    end
    resources "/graders", GraderController, except: [:index, :new, :create]
  end

  scope "/admin", InkfishWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]
    
    resources "/users", UserController
    resources "/courses", CourseController
    resources "/uploads", UploadController
  end

  scope "/ajax", InkfishWeb, as: :ajax do
    pipe_through :ajax

    post "/uploads", UploadController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", InkfishWeb do
  #   pipe_through :api
  # end
end

