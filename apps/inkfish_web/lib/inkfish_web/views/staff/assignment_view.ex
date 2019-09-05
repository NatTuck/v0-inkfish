defmodule InkfishWeb.Staff.AssignmentView do
  use InkfishWeb, :view

  def render("assignment.json", %{assignment: assignment}) do
    bucket = get_assoc(assignment, :bucket)
    teamset = get_assoc(assignment, :teamset)
    gcols = get_assoc(assignment, :grade_columns)
    subs = get_assoc(assignment, :subs) || []

    %{
      name: assignment.name,
      due: assignment.due,
      bucket: bucket,
      teamset: teamset,
      grade_columns: gcols,
      subs: subs,
    }
  end
end
