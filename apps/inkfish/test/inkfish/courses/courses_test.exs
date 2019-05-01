defmodule Inkfish.CoursesTest do
  use Inkfish.DataCase

  alias Inkfish.Courses

  describe "courses" do
    alias Inkfish.Courses.Course

    @valid_attrs %{footer: "some footer", name: "some name", start_date: ~D[2010-04-17]}
    @update_attrs %{footer: "some updated footer", name: "some updated name", start_date: ~D[2011-05-18]}
    @invalid_attrs %{footer: nil, name: nil, start_date: nil}

    def course_fixture(attrs \\ %{}) do
      {:ok, course} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Courses.create_course()

      course
    end

    test "list_courses/0 returns all courses" do
      course = course_fixture()
      assert Courses.list_courses() == [course]
    end

    test "get_course!/1 returns the course with given id" do
      course = course_fixture()
      assert Courses.get_course!(course.id) == course
    end

    test "create_course/1 with valid data creates a course" do
      assert {:ok, %Course{} = course} = Courses.create_course(@valid_attrs)
      assert course.footer == "some footer"
      assert course.name == "some name"
      assert course.start_date == ~D[2010-04-17]
    end

    test "create_course/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Courses.create_course(@invalid_attrs)
    end

    test "update_course/2 with valid data updates the course" do
      course = course_fixture()
      assert {:ok, %Course{} = course} = Courses.update_course(course, @update_attrs)
      assert course.footer == "some updated footer"
      assert course.name == "some updated name"
      assert course.start_date == ~D[2011-05-18]
    end

    test "update_course/2 with invalid data returns error changeset" do
      course = course_fixture()
      assert {:error, %Ecto.Changeset{}} = Courses.update_course(course, @invalid_attrs)
      assert course == Courses.get_course!(course.id)
    end

    test "delete_course/1 deletes the course" do
      course = course_fixture()
      assert {:ok, %Course{}} = Courses.delete_course(course)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_course!(course.id) end
    end

    test "change_course/1 returns a course changeset" do
      course = course_fixture()
      assert %Ecto.Changeset{} = Courses.change_course(course)
    end
  end

  describe "buckets" do
    alias Inkfish.Courses.Bucket

    @valid_attrs %{name: "some name", weight: "120.5"}
    @update_attrs %{name: "some updated name", weight: "456.7"}
    @invalid_attrs %{name: nil, weight: nil}

    def bucket_fixture(attrs \\ %{}) do
      {:ok, bucket} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Courses.create_bucket()

      bucket
    end

    test "list_buckets/0 returns all buckets" do
      bucket = bucket_fixture()
      assert Courses.list_buckets() == [bucket]
    end

    test "get_bucket!/1 returns the bucket with given id" do
      bucket = bucket_fixture()
      assert Courses.get_bucket!(bucket.id) == bucket
    end

    test "create_bucket/1 with valid data creates a bucket" do
      assert {:ok, %Bucket{} = bucket} = Courses.create_bucket(@valid_attrs)
      assert bucket.name == "some name"
      assert bucket.weight == Decimal.new("120.5")
    end

    test "create_bucket/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Courses.create_bucket(@invalid_attrs)
    end

    test "update_bucket/2 with valid data updates the bucket" do
      bucket = bucket_fixture()
      assert {:ok, %Bucket{} = bucket} = Courses.update_bucket(bucket, @update_attrs)
      assert bucket.name == "some updated name"
      assert bucket.weight == Decimal.new("456.7")
    end

    test "update_bucket/2 with invalid data returns error changeset" do
      bucket = bucket_fixture()
      assert {:error, %Ecto.Changeset{}} = Courses.update_bucket(bucket, @invalid_attrs)
      assert bucket == Courses.get_bucket!(bucket.id)
    end

    test "delete_bucket/1 deletes the bucket" do
      bucket = bucket_fixture()
      assert {:ok, %Bucket{}} = Courses.delete_bucket(bucket)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_bucket!(bucket.id) end
    end

    test "change_bucket/1 returns a bucket changeset" do
      bucket = bucket_fixture()
      assert %Ecto.Changeset{} = Courses.change_bucket(bucket)
    end
  end
end
