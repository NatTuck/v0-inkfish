defmodule Inkfish.LineCommentsTest do
  use Inkfish.DataCase
  import Inkfish.Factory

  alias Inkfish.LineComments

  describe "line_comments" do
    alias Inkfish.LineComments.LineComment

    def line_comment_fixture(attrs \\ %{}) do
      insert(:line_comment, attrs)
    end

    test "list_line_comments/0 returns all line_comments" do
      line_comment = line_comment_fixture()
      xs = LineComments.list_line_comments()
      ys = [line_comment]
      assert drop_assocs(xs) == drop_assocs(ys)
    end

    test "get_line_comment!/1 returns the line_comment with given id" do
      line_comment = line_comment_fixture()
      assert drop_assocs(LineComments.get_line_comment!(line_comment.id)) == drop_assocs(line_comment)
    end

    test "create_line_comment/1 with valid data creates a line_comment" do
      params = params_with_assocs(:line_comment)
      assert {:ok, %LineComment{} = line_comment} = LineComments.create_line_comment(params)
      assert line_comment.line == 10
      assert line_comment.path == "hw03/main.c"
      assert line_comment.points == Decimal.new("-5.0")
      assert line_comment.text == "Don't mix tabs and spaces"
    end

    test "create_line_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = LineComments.create_line_comment(%{})
    end

    test "update_line_comment/2 with valid data updates the line_comment" do
      line_comment = line_comment_fixture()
      attrs = %{ line: 43, points: "25.0" }
      assert {:ok, %LineComment{} = lc} = LineComments.update_line_comment(line_comment, attrs)
      assert lc.line == 43
      assert lc.path == line_comment.path
      assert lc.points == Decimal.new("25.0")
      assert lc.text == line_comment.text
    end

    test "update_line_comment/2 with invalid data returns error changeset" do
      line_comment = line_comment_fixture()
      params = %{ grade_id: nil }
      assert {:error, %Ecto.Changeset{}} = LineComments.update_line_comment(line_comment, params)
      assert drop_assocs(line_comment) == drop_assocs(LineComments.get_line_comment!(line_comment.id))
    end

    test "delete_line_comment/1 deletes the line_comment" do
      line_comment = line_comment_fixture()
      assert {:ok, %LineComment{}} = LineComments.delete_line_comment(line_comment)
      assert_raise Ecto.NoResultsError, fn -> LineComments.get_line_comment!(line_comment.id) end
    end

    test "change_line_comment/1 returns a line_comment changeset" do
      line_comment = line_comment_fixture()
      assert %Ecto.Changeset{} = LineComments.change_line_comment(line_comment)
    end
  end
end
