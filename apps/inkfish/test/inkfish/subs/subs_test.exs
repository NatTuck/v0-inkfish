defmodule Inkfish.SubsTest do
  use Inkfish.DataCase
  import Inkfish.Factory

  alias Inkfish.Subs

  describe "subs" do
    alias Inkfish.Subs.Sub

    def sub_fixture(attrs \\ %{}) do
      insert(:sub, attrs)
    end

    test "list_subs/0 returns all subs" do
      sub = sub_fixture()
      assert drop_assocs(Subs.list_subs()) == drop_assocs([sub])
    end

    test "get_sub!/1 returns the sub with given id" do
      sub = sub_fixture()
      assert drop_assocs(Subs.get_sub!(sub.id)) == drop_assocs(sub)
    end

    test "create_sub/1 with valid data creates a sub" do
      attrs = params_with_assocs(:sub)
      assert {:ok, %Sub{} = sub} = Subs.create_sub(attrs)
      assert sub.active == false
      assert sub.hours_spent == Decimal.new("4.5")
    end

    test "create_sub/1 with invalid data returns error changeset" do
      attrs = Map.put(params_for(:sub), :hours_spent, nil)
      assert {:error, %Ecto.Changeset{}} = Subs.create_sub(attrs)
    end

    test "update_sub_ignore_late/2 updates the sub" do
      sub = sub_fixture()
      attrs = %{"ignore_late_penalty" => true}
      assert %Sub{} = sub = Subs.update_sub_ignore_late(sub, attrs)
      assert sub.active == true
      assert sub.ignore_late_penalty == true
    end

    test "update_sub/2 with invalid data returns error changeset" do
      sub = sub_fixture()
      params = %{ params_for(:sub) | hours_spent: nil }
      assert {:error, %Ecto.Changeset{}} = Subs.update_sub(sub, params)
      assert drop_assocs(sub) == drop_assocs(Subs.get_sub!(sub.id))
    end

    test "change_sub/1 returns a sub changeset" do
      sub = sub_fixture()
      assert %Ecto.Changeset{} = Subs.change_sub(sub)
    end
  end
end
