
defmodule U do
  import InkfishWeb.ViewHelpers

  def de("∅"), do: ""
  def de(x), do: x

  def show(x) do
    x
    |> show_score
    |> de
  end
end

alias Inkfish.Courses
alias Inkfish.Grades.Gradesheet
import InkfishWeb.ViewHelpers

argv = System.argv()
IO.inspect({:argv, argv})

[course_id, output_path] = argv
{id, _} = Integer.parse(course_id)

course = Courses.get_course_for_gradesheet!(id)
sheet = Gradesheet.from_course(course)

asgns = Enum.flat_map Enum.sort_by(course.buckets, &(&1.name)), fn bucket ->
  for as <- Enum.sort_by(bucket.assignments, &(&1.name)) do
    as.name
  end
end

asgns = Enum.join(asgns, "\t")

{:ok, fh} = File.open(output_path, [:write, :utf8])

IO.puts(fh, "# Grades for: #{course.name}")
IO.puts(fh, "Name\tTotal\t#{asgns}")

Enum.each course.regs, fn reg ->
  student = sheet.students[reg.id]
  name = user_display_name(reg.user)

  grades = Enum.flat_map Enum.sort_by(course.buckets, &(&1.name)), fn bucket ->
    bs = student.buckets[bucket.id]
    for as <- Enum.sort_by(bucket.assignments, &(&1.name)) do
      bs.scores[as.id]
    end
  end
  gs = Enum.join(Enum.map(grades, &U.show/1), "\t")
  IO.puts(fh, "#{name}\t#{U.show(student.total)}\t#{gs}")
end

:ok = File.close(fh)
