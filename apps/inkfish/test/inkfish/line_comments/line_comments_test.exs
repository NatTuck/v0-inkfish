defmodule Inkfish.LineCommentsTest do
  use Inkfish.DataCase

  alias Inkfish.LineComments

  describe "line_comments" do
    alias Inkfish.LineComments.LineComment

    @valid_attrs %{line: 42, path: "some path", points: "120.5", text: "some text"}
    @update_attrs %{line: 43, path: "some updated path", points: "456.7", text: "some updated text"}
    @invalid_attrs %{line: nil, path: nil, points: nil, text: nil}

    def line_comment_fixture(attrs \\ %{}) do
      {:ok, line_comment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> LineComments.create_line_comment()

      line_comment
    end

    test "list_line_comments/0 returns all line_comments" do
      line_comment = line_comment_fixture()
      assert LineComments.list_line_comments() == [line_comment]
    end

    test "get_line_comment!/1 returns the line_comment with given id" do
      line_comment = line_comment_fixture()
      assert LineComments.get_line_comment!(line_comment.id) == line_comment
    end

    test "create_line_comment/1 with valid data creates a line_comment" do
      assert {:ok, %LineComment{} = line_comment} = LineComments.create_line_comment(@valid_attrs)
      assert line_comment.line == 42
      assert line_comment.path == "some path"
      assert line_comment.points == Decimal.new("120.5")
      assert line_comment.text == "some text"
    end

    test "create_line_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = LineComments.create_line_comment(@invalid_attrs)
    end

    test "update_line_comment/2 with valid data updates the line_comment" do
      line_comment = line_comment_fixture()
      assert {:ok, %LineComment{} = line_comment} = LineComments.update_line_comment(line_comment, @update_attrs)
      assert line_comment.line == 43
      assert line_comment.path == "some updated path"
      assert line_comment.points == Decimal.new("456.7")
      assert line_comment.text == "some updated text"
    end

    test "update_line_comment/2 with invalid data returns error changeset" do
      line_comment = line_comment_fixture()
      assert {:error, %Ecto.Changeset{}} = LineComments.update_line_comment(line_comment, @invalid_attrs)
      assert line_comment == LineComments.get_line_comment!(line_comment.id)
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
