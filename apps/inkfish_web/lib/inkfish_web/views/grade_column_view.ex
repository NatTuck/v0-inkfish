defmodule InkfishWeb.GradeColumnView do
  use InkfishWeb, :view

  def render("grade_column.json", %{grade_column: gc}) do
    %{
      kind: gc.kind,
      name: gc.name,
      base: gc.base,
      points: gc.points,
    }
  end
end
