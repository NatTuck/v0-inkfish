defmodule InkfishWeb.CloneChannelTest do
  use InkfishWeb.ChannelCase

  setup do
    user = Inkfish.Users.get_user_by_login!("bob")

    {:ok, _, socket} =
      socket(InkfishWeb.UserSocket, nil, %{user_id: user.id})
      |> subscribe_and_join(InkfishWeb.CloneChannel, "clone:101")

    {:ok, socket: socket}
  end

  test "clone clones a git repo", %{socket: socket} do
    pancake = "https://github.com/NatTuck/pancake.git"
    _ref = push socket, "clone", %{"url" => pancake}
    assert_push "done", %{upload_id: _uuid}, 2_000
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
