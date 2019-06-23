defmodule Inkfish.GradesTest do
  use Inkfish.DataCase

  alias Inkfish.Grades

  describe "graders" do
    alias Inkfish.Grades.Grader

    @valid_attrs %{kind: "some kind", name: "some name", params: "some params", points: "120.5", weight: "120.5"}
    @update_attrs %{kind: "some updated kind", name: "some updated name", params: "some updated params", points: "456.7", weight: "456.7"}
    @invalid_attrs %{kind: nil, name: nil, params: nil, points: nil, weight: nil}

    def grader_fixture(attrs \\ %{}) do
      {:ok, grader} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Grades.create_grader()

      grader
    end

    test "list_graders/0 returns all graders" do
      grader = grader_fixture()
      assert Grades.list_graders() == [grader]
    end

    test "get_grader!/1 returns the grader with given id" do
      grader = grader_fixture()
      assert Grades.get_grader!(grader.id) == grader
    end

    test "create_grader/1 with valid data creates a grader" do
      assert {:ok, %Grader{} = grader} = Grades.create_grader(@valid_attrs)
      assert grader.kind == "some kind"
      assert grader.name == "some name"
      assert grader.params == "some params"
      assert grader.points == Decimal.new("120.5")
      assert grader.weight == Decimal.new("120.5")
    end

    test "create_grader/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grades.create_grader(@invalid_attrs)
    end

    test "update_grader/2 with valid data updates the grader" do
      grader = grader_fixture()
      assert {:ok, %Grader{} = grader} = Grades.update_grader(grader, @update_attrs)
      assert grader.kind == "some updated kind"
      assert grader.name == "some updated name"
      assert grader.params == "some updated params"
      assert grader.points == Decimal.new("456.7")
      assert grader.weight == Decimal.new("456.7")
    end

    test "update_grader/2 with invalid data returns error changeset" do
      grader = grader_fixture()
      assert {:error, %Ecto.Changeset{}} = Grades.update_grader(grader, @invalid_attrs)
      assert grader == Grades.get_grader!(grader.id)
    end

    test "delete_grader/1 deletes the grader" do
      grader = grader_fixture()
      assert {:ok, %Grader{}} = Grades.delete_grader(grader)
      assert_raise Ecto.NoResultsError, fn -> Grades.get_grader!(grader.id) end
    end

    test "change_grader/1 returns a grader changeset" do
      grader = grader_fixture()
      assert %Ecto.Changeset{} = Grades.change_grader(grader)
    end
  end
end
