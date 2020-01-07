defmodule InkfishWeb.AutogradeChannelTest do
  use InkfishWeb.ChannelCase

  setup do
    user = Inkfish.Users.get_user_by_login!("bob")
    nonce = Base.encode16(:crypto.strong_rand_bytes(32))
    token = Phoenix.Token.sign(InkfishWeb.Endpoint, "autograde", %{uuid: nonce})

    {:ok, _, socket} =
      socket(InkfishWeb.UserSocket, nil, %{user_id: user.id})
      |> subscribe_and_join(
           InkfishWeb.AutogradeChannel,
           "autograde:" <> nonce,
           %{"token" => token}
      )
    {:ok, socket: socket}
  end

  # TODO: Probably fake an autograding process to test this
  # and maybe the git channel with a dummy script.
  @tag :skip
  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
