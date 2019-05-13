defmodule InkfishWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import InkfishWeb.ConnCase
      alias InkfishWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint InkfishWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Inkfish.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Inkfish.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
  
  import Plug.Conn
  import Plug.Test
 
  def login(conn, login) do
    user = Inkfish.Users.get_user_by_login!(login)
    conn
    |> init_test_session(%{user_id: user.id})
    #|> assign(:current_user, user)
    #|> assign(:current_user_id, user.id)
  end
end
