defmodule Inkfish.GradesTest do
  use Inkfish.DataCase
  import Inkfish.Factory

  alias Inkfish.Grades

  describe "grades" do
    alias Inkfish.Grades.Grade

    def grade_fixture(attrs \\ %{}) do
      insert(:grade, attrs)
    end

    test "list_grades/0 returns all grades" do
      grade = grade_fixture()
      assert drop_assocs(Grades.list_grades()) == drop_assocs([grade])
    end

    test "get_grade!/1 returns the grade with given id" do
      grade = grade_fixture()
      assert drop_assocs(Grades.get_grade!(grade.id)) == drop_assocs(grade)
    end

    test "create_grade/1 with valid data creates a grade" do
      params = params_with_assocs(:grade)
      assert {:ok, %Grade{} = grade} = Grades.create_grade(params)
      assert grade.score == Decimal.new("45.7")
    end

    test "create_grade/1 with invalid data returns error changeset" do
      params = %{}
      assert {:error, %Ecto.Changeset{}} = Grades.create_grade(params)
    end

    test "update_grade/2 with valid data updates the grade" do
      grade = grade_fixture()
      params = %{score: "25.1"}
      assert {:ok, %Grade{} = grade} = Grades.update_grade(grade, params)
      assert grade.score == Decimal.new("25.1")
    end

    test "update_grade/2 with invalid data returns error changeset" do
      grade = grade_fixture()
      params = %{score: "", sub_id: ""}
      assert {:error, %Ecto.Changeset{}} = Grades.update_grade(grade, params)
      assert drop_assocs(grade) == drop_assocs(Grades.get_grade!(grade.id))
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

    def grade_column_fixture(attrs \\ %{}) do
      insert(:grade_column, attrs)
    end

    test "list_grade_columns/0 returns all grade_columns" do
      grade_column = grade_column_fixture()
      assert drop_assocs(Grades.list_grade_columns()) == drop_assocs([grade_column])
    end

    test "get_grade_column!/1 returns the grade_column with given id" do
      grade_column = grade_column_fixture()
      assert drop_assocs(Grades.get_grade_column!(grade_column.id)) == drop_assocs(grade_column)
    end

    test "create_grade_column/1 with valid data creates a grade_column" do
      params = params_with_assocs(:grade_column)
      assert {:ok, %GradeColumn{} = grade_column} = Grades.create_grade_column(params)
      assert grade_column.kind == "number"
      assert grade_column.name == "Number Grade"
      assert grade_column.points == Decimal.new("50.0")
      assert grade_column.base == Decimal.new("40.0")
    end

    test "create_grade_column/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grades.create_grade_column(%{})
    end

    test "update_grade_column/2 with valid data updates the grade_column" do
      grade_column = grade_column_fixture()
      params = %{ name: "Updated", base: "30.0" }
      assert {:ok, %GradeColumn{} = gc1} = Grades.update_grade_column(grade_column, params)
      assert gc1.kind == grade_column.kind
      assert gc1.name == "Updated"
      assert gc1.params == grade_column.params
      assert gc1.points == grade_column.points
      assert gc1.base == Decimal.new("30.0")
    end

    test "update_grade_column/2 with invalid data returns error changeset" do
      grade_column = grade_column_fixture()
      params = %{points: ""}
      assert {:error, %Ecto.Changeset{}} = Grades.update_grade_column(grade_column, params)
      assert drop_assocs(grade_column) == drop_assocs(Grades.get_grade_column!(grade_column.id))
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
