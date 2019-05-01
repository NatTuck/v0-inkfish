defmodule Inkfish.UsersTest do
  use Inkfish.DataCase

  alias Inkfish.Users

  describe "users" do
    alias Inkfish.Users.User

    @valid_attrs %{email: "some email", is_admin: true}
    @update_attrs %{email: "some updated email", is_admin: false}
    @invalid_attrs %{email: nil, is_admin: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.is_admin == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Users.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.is_admin == false
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end

  describe "regs" do
    alias Inkfish.Users.Reg

    @valid_attrs %{is_grader: true, is_prof: true, is_staff: true, is_student: true}
    @update_attrs %{is_grader: false, is_prof: false, is_staff: false, is_student: false}
    @invalid_attrs %{is_grader: nil, is_prof: nil, is_staff: nil, is_student: nil}

    def reg_fixture(attrs \\ %{}) do
      {:ok, reg} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_reg()

      reg
    end

    test "list_regs/0 returns all regs" do
      reg = reg_fixture()
      assert Users.list_regs() == [reg]
    end

    test "get_reg!/1 returns the reg with given id" do
      reg = reg_fixture()
      assert Users.get_reg!(reg.id) == reg
    end

    test "create_reg/1 with valid data creates a reg" do
      assert {:ok, %Reg{} = reg} = Users.create_reg(@valid_attrs)
      assert reg.is_grader == true
      assert reg.is_prof == true
      assert reg.is_staff == true
      assert reg.is_student == true
    end

    test "create_reg/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_reg(@invalid_attrs)
    end

    test "update_reg/2 with valid data updates the reg" do
      reg = reg_fixture()
      assert {:ok, %Reg{} = reg} = Users.update_reg(reg, @update_attrs)
      assert reg.is_grader == false
      assert reg.is_prof == false
      assert reg.is_staff == false
      assert reg.is_student == false
    end

    test "update_reg/2 with invalid data returns error changeset" do
      reg = reg_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_reg(reg, @invalid_attrs)
      assert reg == Users.get_reg!(reg.id)
    end

    test "delete_reg/1 deletes the reg" do
      reg = reg_fixture()
      assert {:ok, %Reg{}} = Users.delete_reg(reg)
      assert_raise Ecto.NoResultsError, fn -> Users.get_reg!(reg.id) end
    end

    test "change_reg/1 returns a reg changeset" do
      reg = reg_fixture()
      assert %Ecto.Changeset{} = Users.change_reg(reg)
    end
  end
end
