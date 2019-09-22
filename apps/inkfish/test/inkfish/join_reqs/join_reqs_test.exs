defmodule Inkfish.JoinReqsTest do
  use Inkfish.DataCase
  import Inkfish.Factory

  alias Inkfish.JoinReqs

  describe "join_reqs" do
    alias Inkfish.JoinReqs.JoinReq

    test "list_join_reqs/0 returns all join_reqs" do
      join_req = insert(:join_req)
      assert drop_assocs(JoinReqs.list_join_reqs()) == drop_assocs([join_req])
    end

    test "get_join_req!/1 returns the join_req with given id" do
      join_req = insert(:join_req)
      assert drop_assocs(JoinReqs.get_join_req!(join_req.id)) == drop_assocs(join_req)
    end

    test "create_join_req/1 with valid data creates a join_req" do
      attrs = params_with_assocs(:join_req)
      assert {:ok, %JoinReq{} = join_req} = JoinReqs.create_join_req(attrs)
      assert join_req.user_id == attrs.user_id
      assert join_req.course_id == attrs.course_id
      assert join_req.note == "let me in"
      assert join_req.staff_req == false
    end

    test "create_join_req/1 with invalid data returns error changeset" do
      attrs = params_for(:join_req)
      Map.put(attrs, :user_id, 0)
      assert {:error, %Ecto.Changeset{}} = JoinReqs.create_join_req(attrs)
    end

    test "delete_join_req/1 deletes the join_req" do
      join_req = insert(:join_req)
      assert {:ok, %JoinReq{}} = JoinReqs.delete_join_req(join_req)
      assert_raise Ecto.NoResultsError, fn -> JoinReqs.get_join_req!(join_req.id) end
    end

    test "change_join_req/1 returns a join_req changeset" do
      join_req = insert(:join_req)
      assert %Ecto.Changeset{} = JoinReqs.change_join_req(join_req)
    end
  end
end
