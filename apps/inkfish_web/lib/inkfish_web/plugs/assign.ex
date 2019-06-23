defmodule InkfishWeb.Plugs.Assign do
  import Plug.Conn

  def init(args), do: args

  def call(conn, args) do
    Enum.reduce args, conn, fn ({key, val}, conn) ->
      assign(conn, key, val)
    end
  end
end
