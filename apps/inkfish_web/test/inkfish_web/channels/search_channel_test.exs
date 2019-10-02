defmodule InkfishWeb.SearchChannelTest do
  use InkfishWeb.ChannelCase

  setup do
    user = Inkfish.Users.get_user_by_login!("alice")

    {:ok, _, socket} =
      socket(InkfishWeb.UserSocket, nil, %{user_id: user.id})
      |> subscribe_and_join(InkfishWeb.SearchChannel, "search:users")

    {:ok, socket: socket}
  end

  test "query returns carol", %{socket: socket} do
    ref = push socket, "q", "carol"
    assert_reply ref, :ok, %{matches: ["carol (Carol Anderson)"]}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
