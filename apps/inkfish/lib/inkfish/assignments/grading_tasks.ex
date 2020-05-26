defmodule Inkfish.Assignments.GradingTasks do
  import Ecto.Query, warn: false
  alias Inkfish.Repo

  alias Inkfish.Courses
  alias Inkfish.Assignments
  alias Inkfish.Assignments.Assignment
  alias Inkfish.Grades
  alias Inkfish.Grades.Grade
  alias Inkfish.Users.Reg
  alias Inkfish.Subs.Sub

  def unassign_inactive_subs(as) do
    qq = from grade in Grade,
      inner_join: gcol in assoc(grade, :grade_column),
      inner_join: sub in assoc(grade, :sub),
      inner_join: asg in assoc(sub, :assignment),
      where: gcol.kind == "feedback",
      where: asg.id == ^as.id,
      where: sub.active == false
    Repo.update_all(qq, set: [grader_id: nil])
  end

  def assign_grading_tasks(as) do
    # Make sure we have grade columns.
    as = Repo.preload(as, :grade_columns)

    # Find graders
    graders = Courses.list_course_graders(as.bucket.course_id)

    # Get active subs for assignment
    subs = Assignments.list_active_subs(as)

    gcols = Enum.filter as.grade_columns, &(&1.kind == "feedback")
    Enum.each gcols, fn gcol ->
      assign_tasks_for_gcol(subs, gcol, graders)
    end
  end

  def assign_tasks_for_gcol(_, _, []), do: :ok
  def assign_tasks_for_gcol(subs, gcol, graders) do
    # Find grades; create missing.
    grades = Enum.map subs, fn sub ->
      if grade = Enum.find(sub.grades, &(&1.grade_column_id == gcol.id)) do
        grade
      else
        attrs = %{
          sub_id: sub.id,
          grade_column_id: gcol.id,
        }
        {:ok, grade} = Grades.create_grade(attrs)
        grade
      end
    end

    zeros = graders
    |> Enum.map(&({&1.id, 0}))
    |> Enum.into(%{})

    counts = Enum.reduce grades, zeros, fn (gr, acc) ->
      if gr.grader_id && Map.has_key?(acc, gr.grader_id) do
        Map.update(acc, gr.grader_id, 0, &(&1 + 1))
      else
        acc
      end
    end

    graders = Enum.shuffle(graders)
    grades = grades
    |> Enum.filter(&(&1.grader_id == nil))
    |> Enum.shuffle()

    assign_graders(graders, grades, counts)
  end

  def assign_graders([], [], _), do: :ok
  def assign_graders([grader|graders], grades, counts) do
    grades_each = ceil(length(grades) / (1 + length(graders)))
    count = grades_each - Map.get(counts, grader.id, 0)

    IO.inspect {:tasks_for, grader.login, count}

    Enum.each Enum.take(grades, count), fn grade ->
      {:ok, _} = Grades.update_grade(grade, %{grader_id: grader.id})
    end

    assign_graders(graders, Enum.drop(grades, count), counts)
  end

  def clear_grading_tasks(as) do
    qq = from grade in Grade,
      inner_join: gcol in assoc(grade, :grade_column),
      inner_join: sub in assoc(grade, :sub),
      inner_join: asg in assoc(sub, :assignment),
      where: gcol.kind == "feedback",
      where: asg.id == ^as.id
    Repo.update_all(qq, set: [grader_id: nil])
  end
end
