defmodule Inkfish.JoinReqsTest do
  use Inkfish.DataCase

  alias Inkfish.JoinReqs

  describe "join_reqs" do
    alias Inkfish.JoinReqs.JoinReq

    @valid_attrs %{login: "some login", note: "some note", staff_req: true}
    @update_attrs %{login: "some updated login", note: "some updated note", staff_req: false}
    @invalid_attrs %{login: nil, note: nil, staff_req: nil}

    def join_req_fixture(attrs \\ %{}) do
      {:ok, join_req} =
        attrs
        |> Enum.into(@valid_attrs)
        |> JoinReqs.create_join_req()

      join_req
    end

    test "list_join_reqs/0 returns all join_reqs" do
      join_req = join_req_fixture()
      assert JoinReqs.list_join_reqs() == [join_req]
    end

    test "get_join_req!/1 returns the join_req with given id" do
      join_req = join_req_fixture()
      assert JoinReqs.get_join_req!(join_req.id) == join_req
    end

    test "create_join_req/1 with valid data creates a join_req" do
      assert {:ok, %JoinReq{} = join_req} = JoinReqs.create_join_req(@valid_attrs)
      assert join_req.login == "some login"
      assert join_req.note == "some note"
      assert join_req.staff_req == true
    end

    test "create_join_req/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = JoinReqs.create_join_req(@invalid_attrs)
    end

    test "update_join_req/2 with valid data updates the join_req" do
      join_req = join_req_fixture()
      assert {:ok, %JoinReq{} = join_req} = JoinReqs.update_join_req(join_req, @update_attrs)
      assert join_req.login == "some updated login"
      assert join_req.note == "some updated note"
      assert join_req.staff_req == false
    end

    test "update_join_req/2 with invalid data returns error changeset" do
      join_req = join_req_fixture()
      assert {:error, %Ecto.Changeset{}} = JoinReqs.update_join_req(join_req, @invalid_attrs)
      assert join_req == JoinReqs.get_join_req!(join_req.id)
    end

    test "delete_join_req/1 deletes the join_req" do
      join_req = join_req_fixture()
      assert {:ok, %JoinReq{}} = JoinReqs.delete_join_req(join_req)
      assert_raise Ecto.NoResultsError, fn -> JoinReqs.get_join_req!(join_req.id) end
    end

    test "change_join_req/1 returns a join_req changeset" do
      join_req = join_req_fixture()
      assert %Ecto.Changeset{} = JoinReqs.change_join_req(join_req)
    end
  end
end
