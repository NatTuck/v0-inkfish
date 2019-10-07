defmodule InkfishWeb.Admin.UploadController do
  use InkfishWeb, :controller

  alias Inkfish.Uploads
  alias Inkfish.Uploads.Upload

  plug InkfishWeb.Plugs.RequireUser, admin: true

  def index(conn, _params) do
    uploads = Uploads.list_uploads()
    render(conn, "index.html", uploads: uploads)
  end
end
