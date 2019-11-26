
alias Inkfish.Courses
alias Inkfish.Grades.Gradesheet

course = Courses.get_course_for_gradesheet!(1)
sheet = Gradesheet.from_course(course)
IO.inspect(sheet.stats)
