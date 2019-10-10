defmodule Inkfish.TeamsTest do
  use Inkfish.DataCase
  import Inkfish.Factory

  alias Inkfish.Teams

  describe "teams" do
    alias Inkfish.Teams.Team

    def team_fixture(attrs \\ %{}) do
      insert(:team, attrs)
    end

    test "list_teams/0 returns all teams" do
      ts = insert(:teamset)
      t1 = insert(:team, teamset: ts)
      assert drop_assocs(Teams.list_teams(ts.id)) == drop_assocs([t1])
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert drop_assocs(Teams.get_team!(team.id)) == drop_assocs(team)
    end

    test "create_team/1 with valid data creates a team" do
      params = params_with_assocs(:team)
      assert {:ok, %Team{} = team} = Teams.create_team(params)
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(%{})
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      ts = insert(:teamset)
      params = %{teamset_id: ts.id}
      assert {:ok, %Team{} = team} = Teams.update_team(team, params)
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      params = %{teamset_id: -1}
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, params)
      assert drop_assocs(team) == drop_assocs(Teams.get_team!(team.id))
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

    def team_member_fixture(attrs \\ %{}) do
      insert(:team_member, attrs)
    end

    test "list_team_members/0 returns all team_members" do
      team_member = team_member_fixture()
      assert drop_assocs(Teams.list_team_members()) == drop_assocs([team_member])
    end

    test "get_team_member!/1 returns the team_member with given id" do
      team_member = team_member_fixture()
      assert drop_assocs(Teams.get_team_member!(team_member.id)) == drop_assocs(team_member)
    end

    test "create_team_member/1 with valid data creates a team_member" do
      params = params_with_assocs(:team_member)
      assert {:ok, %TeamMember{} = team_member} = Teams.create_team_member(params)
    end

    test "create_team_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team_member(%{})
    end

    test "update_team_member/2 with valid data updates the team_member" do
      team_member = team_member_fixture()
      team = insert(:team)
      params = %{team_id: team.id}
      assert {:ok, %TeamMember{} = team_member} = Teams.update_team_member(team_member, params)
    end

    test "update_team_member/2 with invalid data returns error changeset" do
      team_member = team_member_fixture()
      params = %{team_id: -1}
      assert {:error, %Ecto.Changeset{}} = Teams.update_team_member(team_member, params)
      assert drop_assocs(team_member) == drop_assocs(Teams.get_team_member!(team_member.id))
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
