defmodule Inkfish.CoursesTest do
  use Inkfish.DataCase
  import Inkfish.Factory

  alias Inkfish.Courses

  describe "courses" do
    alias Inkfish.Courses.Course

    test "list_courses/0 returns courses" do
      _course = insert(:course)
      assert [%Course{} | _] = Courses.list_courses()
    end

    test "get_course!/1 returns the course with given id" do
      course0 = insert(:course)
      course1 = Courses.get_course!(course0.id)
      assert course1.name == course0.name
      assert course1.solo_teamset_id != nil
    end

    test "get_course!/1 creates a solo teamset if needed" do
      course0 = insert(:course)
      assert course0.solo_teamset_id == nil
      course1 = Courses.get_course!(course0.id)
      assert course1.solo_teamset_id != nil
      course2 = Courses.get_course!(course0.id)
      assert course1.solo_teamset_id == course2.solo_teamset_id
    end

    test "create_course/1 with valid data creates a course" do
      attrs = params_for(:course)
      assert {:ok, %Course{} = course} = Courses.create_course(attrs)
      assert course.footer == ""
      assert course.name =~ ~r/CS\s+\d+/
    end

    test "create_course/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Courses.create_course(%{})
    end

    test "update_course/2 with valid data updates the course" do
      course = insert(:course)
      attrs = %{name: "Industrial Design", footer: "plastic noodles"}
      assert {:ok, %Course{} = course} = Courses.update_course(course, attrs)
      assert course.name == "Industrial Design"
      assert course.footer == "plastic noodles"
    end

    test "update_course/2 with invalid data returns error changeset" do
      course = insert(:course)
      attrs = %{name: ""}
      assert {:error, %Ecto.Changeset{}} = Courses.update_course(course, attrs)
      assert course.name == Courses.get_course!(course.id).name
    end

    test "delete_course/1 deletes the course" do
      course = insert(:course)
      assert {:ok, %Course{}} = Courses.delete_course(course)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_course!(course.id) end
    end

    test "change_course/1 returns a course changeset" do
      course = insert(:course)
      assert %Ecto.Changeset{} = Courses.change_course(course)
    end
  end

  describe "buckets" do
    alias Inkfish.Courses.Bucket
    
    test "list_buckets/0 returns all buckets" do
      bucket = insert(:bucket)
      assert Enum.member?(
        drop_assocs(Courses.list_buckets()),
        drop_assocs(bucket)
      )
    end

    test "get_bucket!/1 returns the bucket with given id" do
      bucket = insert(:bucket)
      assert drop_assocs(Courses.get_bucket!(bucket.id)) == drop_assocs(bucket)
    end

    test "create_bucket/1 with valid data creates a bucket" do
      params = params_for(:bucket)
      |> Map.put(:course_id, insert(:course).id)
      
      assert {:ok, %Bucket{} = bucket} = Courses.create_bucket(params)
      assert bucket.name == "Homework"
      assert bucket.weight == Decimal.new("1.0")
    end

    test "create_bucket/1 with invalid data returns error changeset" do
      attrs = %{weight: "-0.1"}
      assert {:error, %Ecto.Changeset{}} = Courses.create_bucket(attrs)
    end

    test "update_bucket/2 with valid data updates the bucket" do
      bucket = insert(:bucket)
      attrs = %{weight: "0.5"}
      assert {:ok, %Bucket{} = bucket} = Courses.update_bucket(bucket, attrs)
      assert bucket.weight == Decimal.new("0.5")
    end

    test "update_bucket/2 with invalid data returns error changeset" do
      bucket = insert(:bucket)
      attrs = %{weight: "-0.1"}
      assert {:error, %Ecto.Changeset{}} = Courses.update_bucket(bucket, attrs)
      assert drop_assocs(bucket) == drop_assocs(Courses.get_bucket!(bucket.id))
    end

    test "delete_bucket/1 deletes the bucket" do
      bucket = insert(:bucket)
      assert {:ok, %Bucket{}} = Courses.delete_bucket(bucket)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_bucket!(bucket.id) end
    end

    test "change_bucket/1 returns a bucket changeset" do
      bucket = insert(:bucket)
      assert %Ecto.Changeset{} = Courses.change_bucket(bucket)
    end
  end
end
