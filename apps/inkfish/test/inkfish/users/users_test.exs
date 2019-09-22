defmodule Inkfish.UsersTest do
  use Inkfish.DataCase
  import Inkfish.Factory

  alias Inkfish.Users

  describe "users" do
    alias Inkfish.Users.User

    test "list_users/0 returns users" do
      user = insert(:user)
      users = Users.list_users()
      assert [%User{} |_] = users
      assert Enum.member?(Enum.map(users, &(&1.id)), user.id)
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert drop_assocs(Users.get_user!(user.id)) == drop_assocs(user)
    end

    test "create_user/1 with valid data creates a user" do
      attrs = params_for(:user)
      assert {:ok, %User{} = user} = Users.create_user(attrs)
      assert user.email =~ ~r[sam\d+@example.com];
      assert user.is_admin == false
    end

    test "create_user/1 with invalid data returns error changeset" do
      bad_attrs = %{}
      assert {:error, %Ecto.Changeset{}} = Users.create_user(bad_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      attrs = %{given_name: "Steve"}
      assert {:ok, %User{} = user} = Users.update_user(user, attrs)
      assert user.given_name == "Steve"
      assert user.surname == "Smith"
      assert user.is_admin == false
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      bad_attrs = %{given_name: ""}
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, bad_attrs)
      assert drop_assocs(user) == drop_assocs(Users.get_user!(user.id))
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end

  describe "regs" do
    alias Inkfish.Users.Reg
    
    test "list_regs/0 returns newly inserted reg" do
      reg = insert(:reg)
      regs = Users.list_regs
      assert Enum.member?(Enum.map(regs, &(&1.id)), reg.id)
    end

    test "get_reg!/1 returns the reg with given id" do
      reg = insert(:reg)
      assert drop_assocs(Users.get_reg!(reg.id)) == drop_assocs(reg)
    end

    test "create_reg/1 with valid data creates a reg" do
      params = params_for(:reg)
      |> Map.put(:course_id, insert(:course).id)
      |> Map.put(:user_id, insert(:user).id)
      
      assert {:ok, %Reg{} = reg} = Users.create_reg(params)
      assert reg.is_grader == false
      assert reg.is_prof == false
      assert reg.is_staff == false
      assert reg.is_student == true
    end

    test "create_reg/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_reg(%{})
    end

    test "update_reg/2 with valid data updates the reg" do
      reg = insert(:reg)
      assert {:ok, %Reg{} = reg} = Users.update_reg(reg, %{is_student: true})
      assert reg.is_grader == false
      assert reg.is_prof == false
      assert reg.is_staff == false
      assert reg.is_student == true
    end

    test "update_reg/2 with invalid data returns error changeset" do
      reg = insert(:reg)
      params = %{is_student: true, is_prof: true}
      assert {:error, %Ecto.Changeset{}} = Users.update_reg(reg, params)
      assert drop_assocs(reg) == drop_assocs(Users.get_reg!(reg.id))
    end

    test "delete_reg/1 deletes the reg" do
      reg = insert(:reg)
      assert {:ok, %Reg{}} = Users.delete_reg(reg)
      assert_raise Ecto.NoResultsError, fn -> Users.get_reg!(reg.id) end
    end

    test "change_reg/1 returns a reg changeset" do
      reg = insert(:reg)
      assert %Ecto.Changeset{} = Users.change_reg(reg)
    end
  end
end
