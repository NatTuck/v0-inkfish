defmodule Inkfish.GradesTest do
  use Inkfish.DataCase

  alias Inkfish.Grades

  describe "grades" do
    alias Inkfish.Grades.Grade

    @valid_attrs %{score: "120.5"}
    @update_attrs %{score: "456.7"}
    @invalid_attrs %{score: nil}

    def grade_fixture(attrs \\ %{}) do
      {:ok, grade} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Grades.create_grade()

      grade
    end

    test "list_grades/0 returns all grades" do
      grade = grade_fixture()
      assert Grades.list_grades() == [grade]
    end

    test "get_grade!/1 returns the grade with given id" do
      grade = grade_fixture()
      assert Grades.get_grade!(grade.id) == grade
    end

    test "create_grade/1 with valid data creates a grade" do
      assert {:ok, %Grade{} = grade} = Grades.create_grade(@valid_attrs)
      assert grade.score == Decimal.new("120.5")
    end

    test "create_grade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grades.create_grade(@invalid_attrs)
    end

    test "update_grade/2 with valid data updates the grade" do
      grade = grade_fixture()
      assert {:ok, %Grade{} = grade} = Grades.update_grade(grade, @update_attrs)
      assert grade.score == Decimal.new("456.7")
    end

    test "update_grade/2 with invalid data returns error changeset" do
      grade = grade_fixture()
      assert {:error, %Ecto.Changeset{}} = Grades.update_grade(grade, @invalid_attrs)
      assert grade == Grades.get_grade!(grade.id)
    end

    test "delete_grade/1 deletes the grade" do
      grade = grade_fixture()
      assert {:ok, %Grade{}} = Grades.delete_grade(grade)
      assert_raise Ecto.NoResultsError, fn -> Grades.get_grade!(grade.id) end
    end

    test "change_grade/1 returns a grade changeset" do
      grade = grade_fixture()
      assert %Ecto.Changeset{} = Grades.change_grade(grade)
    end
  end

  describe "grade_columns" do
    alias Inkfish.Grades.GradeColumn

    @valid_attrs %{kind: "some kind", name: "some name", params: "some params", points: "120.5", weight: "120.5"}
    @update_attrs %{kind: "some updated kind", name: "some updated name", params: "some updated params", points: "456.7", weight: "456.7"}
    @invalid_attrs %{kind: nil, name: nil, params: nil, points: nil, weight: nil}

    def grade_column_fixture(attrs \\ %{}) do
      {:ok, grade_column} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Grades.create_grade_column()

      grade_column
    end

    test "list_grade_columns/0 returns all grade_columns" do
      grade_column = grade_column_fixture()
      assert Grades.list_grade_columns() == [grade_column]
    end

    test "get_grade_column!/1 returns the grade_column with given id" do
      grade_column = grade_column_fixture()
      assert Grades.get_grade_column!(grade_column.id) == grade_column
    end

    test "create_grade_column/1 with valid data creates a grade_column" do
      assert {:ok, %GradeColumn{} = grade_column} = Grades.create_grade_column(@valid_attrs)
      assert grade_column.kind == "some kind"
      assert grade_column.name == "some name"
      assert grade_column.params == "some params"
      assert grade_column.points == Decimal.new("120.5")
      assert grade_column.weight == Decimal.new("120.5")
    end

    test "create_grade_column/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grades.create_grade_column(@invalid_attrs)
    end

    test "update_grade_column/2 with valid data updates the grade_column" do
      grade_column = grade_column_fixture()
      assert {:ok, %GradeColumn{} = grade_column} = Grades.update_grade_column(grade_column, @update_attrs)
      assert grade_column.kind == "some updated kind"
      assert grade_column.name == "some updated name"
      assert grade_column.params == "some updated params"
      assert grade_column.points == Decimal.new("456.7")
      assert grade_column.weight == Decimal.new("456.7")
    end

    test "update_grade_column/2 with invalid data returns error changeset" do
      grade_column = grade_column_fixture()
      assert {:error, %Ecto.Changeset{}} = Grades.update_grade_column(grade_column, @invalid_attrs)
      assert grade_column == Grades.get_grade_column!(grade_column.id)
    end

    test "delete_grade_column/1 deletes the grade_column" do
      grade_column = grade_column_fixture()
      assert {:ok, %GradeColumn{}} = Grades.delete_grade_column(grade_column)
      assert_raise Ecto.NoResultsError, fn -> Grades.get_grade_column!(grade_column.id) end
    end

    test "change_grade_column/1 returns a grade_column changeset" do
      grade_column = grade_column_fixture()
      assert %Ecto.Changeset{} = Grades.change_grade_column(grade_column)
    end
  end
end
