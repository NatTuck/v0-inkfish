defmodule Inkfish.SubsTest do
  use Inkfish.DataCase

  alias Inkfish.Subs

  describe "subs" do
    alias Inkfish.Subs.Sub

    @valid_attrs %{active: true, score: "120.5"}
    @update_attrs %{active: false, score: "456.7"}
    @invalid_attrs %{active: nil, score: nil}

    def sub_fixture(attrs \\ %{}) do
      {:ok, sub} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Subs.create_sub()

      sub
    end

    test "list_subs/0 returns all subs" do
      sub = sub_fixture()
      assert Subs.list_subs() == [sub]
    end

    test "get_sub!/1 returns the sub with given id" do
      sub = sub_fixture()
      assert Subs.get_sub!(sub.id) == sub
    end

    test "create_sub/1 with valid data creates a sub" do
      assert {:ok, %Sub{} = sub} = Subs.create_sub(@valid_attrs)
      assert sub.active == true
      assert sub.score == Decimal.new("120.5")
    end

    test "create_sub/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subs.create_sub(@invalid_attrs)
    end

    test "update_sub/2 with valid data updates the sub" do
      sub = sub_fixture()
      assert {:ok, %Sub{} = sub} = Subs.update_sub(sub, @update_attrs)
      assert sub.active == false
      assert sub.score == Decimal.new("456.7")
    end

    test "update_sub/2 with invalid data returns error changeset" do
      sub = sub_fixture()
      assert {:error, %Ecto.Changeset{}} = Subs.update_sub(sub, @invalid_attrs)
      assert sub == Subs.get_sub!(sub.id)
    end

    test "delete_sub/1 deletes the sub" do
      sub = sub_fixture()
      assert {:ok, %Sub{}} = Subs.delete_sub(sub)
      assert_raise Ecto.NoResultsError, fn -> Subs.get_sub!(sub.id) end
    end

    test "change_sub/1 returns a sub changeset" do
      sub = sub_fixture()
      assert %Ecto.Changeset{} = Subs.change_sub(sub)
    end
  end
end
