defmodule Inkfish.TeamsTest do
  use Inkfish.DataCase

  alias Inkfish.Teams

  describe "teams" do
    alias Inkfish.Teams.Team

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Teams.create_team()

      team
    end

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Teams.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Teams.create_team(@valid_attrs)
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      assert {:ok, %Team{} = team} = Teams.update_team(team, @update_attrs)
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, @invalid_attrs)
      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Teams.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end

  describe "team_members" do
    alias Inkfish.Teams.TeamMember

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def team_member_fixture(attrs \\ %{}) do
      {:ok, team_member} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Teams.create_team_member()

      team_member
    end

    test "list_team_members/0 returns all team_members" do
      team_member = team_member_fixture()
      assert Teams.list_team_members() == [team_member]
    end

    test "get_team_member!/1 returns the team_member with given id" do
      team_member = team_member_fixture()
      assert Teams.get_team_member!(team_member.id) == team_member
    end

    test "create_team_member/1 with valid data creates a team_member" do
      assert {:ok, %TeamMember{} = team_member} = Teams.create_team_member(@valid_attrs)
    end

    test "create_team_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team_member(@invalid_attrs)
    end

    test "update_team_member/2 with valid data updates the team_member" do
      team_member = team_member_fixture()
      assert {:ok, %TeamMember{} = team_member} = Teams.update_team_member(team_member, @update_attrs)
    end

    test "update_team_member/2 with invalid data returns error changeset" do
      team_member = team_member_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team_member(team_member, @invalid_attrs)
      assert team_member == Teams.get_team_member!(team_member.id)
    end

    test "delete_team_member/1 deletes the team_member" do
      team_member = team_member_fixture()
      assert {:ok, %TeamMember{}} = Teams.delete_team_member(team_member)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team_member!(team_member.id) end
    end

    test "change_team_member/1 returns a team_member changeset" do
      team_member = team_member_fixture()
      assert %Ecto.Changeset{} = Teams.change_team_member(team_member)
    end
  end
end
