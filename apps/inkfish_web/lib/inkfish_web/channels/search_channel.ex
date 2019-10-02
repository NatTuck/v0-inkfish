defmodule InkfishWeb.SearchChannel do
  use InkfishWeb, :channel

  alias Inkfish.Users

  def join("search:" <> topic, payload, socket) do
    if authorized?(socket, payload) do
      socket = socket
      |> assign(:topic, topic)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("q", payload, socket) do
    result = search(socket.assigns[:topic], payload)
    {:reply, {:ok, %{matches: result}}, socket}
  end

  def search("users", query) do
    Enum.map Users.search_users(query), fn user ->
      "#{user.login} (#{user.given_name} #{user.surname})"
    end
  end

  # Add authorization logic here as required.
  defp authorized?(socket, _payload) do
    user = Inkfish.Users.get_user!(socket.assigns[:user_id])
    user.is_admin
  end
end

