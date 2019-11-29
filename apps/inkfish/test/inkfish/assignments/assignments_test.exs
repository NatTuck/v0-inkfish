defmodule Inkfish.AssignmentsTest do
  use Inkfish.DataCase
  import Inkfish.Factory

  alias Inkfish.Assignments

  describe "assignments" do
    alias Inkfish.Assignments.Assignment

    def assignment_fixture(attrs \\ %{}) do
      as = insert(:assignment, attrs)
      Assignments.get_assignment!(as.id)
    end

    test "list_assignments/0 returns all assignments" do
      assignment = assignment_fixture()
      assert Enum.member?(
        drop_assocs(Assignments.list_assignments()),
        drop_assocs(assignment)
      )
    end

    test "get_assignment!/1 returns the assignment with given id" do
      assignment = assignment_fixture()
      assert drop_assocs(Assignments.get_assignment!(assignment.id)) == drop_assocs(assignment)
    end

    test "create_assignment/1 with valid data creates a assignment" do
      attrs = params_with_assocs(:assignment)
      assert {:ok, %Assignment{} = assignment} = Assignments.create_assignment(attrs)
      assert assignment.desc == attrs.desc
      assert assignment.due  == attrs.due
      assert assignment.name == attrs.name
      assert assignment.weight == attrs.weight
    end

    test "create_assignment/1 with invalid data returns error changeset" do
      attrs = %{params_for(:assignment) | name: ""}
      assert {:error, %Ecto.Changeset{}} = Assignments.create_assignment(attrs)
    end

    test "update_assignment/2 with valid data updates the assignment" do
      assignment = assignment_fixture()
      attrs = %{ params_for(:assignment) | name: "Updated name" }
      assert {:ok, %Assignment{} = a1} = Assignments.update_assignment(assignment, attrs)
      assert a1.desc == assignment.desc
      assert a1.due == attrs[:due]
      assert a1.name == "Updated name"
      assert a1.weight == assignment.weight
    end

    test "update_assignment/2 with invalid data returns error changeset" do
      assignment = assignment_fixture()
      attrs = %{name: ""}
      assert {:error, %Ecto.Changeset{}} = Assignments.update_assignment(assignment, attrs)
      assert drop_assocs(assignment) == drop_assocs(Assignments.get_assignment!(assignment.id))
    end

    test "delete_assignment/1 deletes the assignment" do
      assignment = assignment_fixture()
      assert {:ok, %Assignment{}} = Assignments.delete_assignment(assignment)
      assert_raise Ecto.NoResultsError, fn -> Assignments.get_assignment!(assignment.id) end
    end

    test "change_assignment/1 returns a assignment changeset" do
      assignment = assignment_fixture()
      assert %Ecto.Changeset{} = Assignments.change_assignment(assignment)
    end
  end
end
