defmodule Inkfish.AssignmentsTest do
  use Inkfish.DataCase

  alias Inkfish.Assignments

  describe "assignments" do
    alias Inkfish.Assignments.Assignment

    @valid_attrs %{desc: "some desc", due: ~N[2010-04-17 14:00:00], name: "some name", weight: "120.5"}
    @update_attrs %{desc: "some updated desc", due: ~N[2011-05-18 15:01:01], name: "some updated name", weight: "456.7"}
    @invalid_attrs %{desc: nil, due: nil, name: nil, weight: nil}

    def assignment_fixture(attrs \\ %{}) do
      {:ok, assignment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Assignments.create_assignment()

      assignment
    end

    test "list_assignments/0 returns all assignments" do
      assignment = assignment_fixture()
      assert Assignments.list_assignments() == [assignment]
    end

    test "get_assignment!/1 returns the assignment with given id" do
      assignment = assignment_fixture()
      assert Assignments.get_assignment!(assignment.id) == assignment
    end

    test "create_assignment/1 with valid data creates a assignment" do
      assert {:ok, %Assignment{} = assignment} = Assignments.create_assignment(@valid_attrs)
      assert assignment.desc == "some desc"
      assert assignment.due == ~N[2010-04-17 14:00:00]
      assert assignment.name == "some name"
      assert assignment.weight == Decimal.new("120.5")
    end

    test "create_assignment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignments.create_assignment(@invalid_attrs)
    end

    test "update_assignment/2 with valid data updates the assignment" do
      assignment = assignment_fixture()
      assert {:ok, %Assignment{} = assignment} = Assignments.update_assignment(assignment, @update_attrs)
      assert assignment.desc == "some updated desc"
      assert assignment.due == ~N[2011-05-18 15:01:01]
      assert assignment.name == "some updated name"
      assert assignment.weight == Decimal.new("456.7")
    end

    test "update_assignment/2 with invalid data returns error changeset" do
      assignment = assignment_fixture()
      assert {:error, %Ecto.Changeset{}} = Assignments.update_assignment(assignment, @invalid_attrs)
      assert assignment == Assignments.get_assignment!(assignment.id)
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
