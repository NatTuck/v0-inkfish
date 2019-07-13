defmodule InkfishWeb.CourseView do
  use InkfishWeb, :view

  def assignment_score(as) do
    if Enum.empty?(as.subs) do
      "∅"
    else
      sub = hd(as.subs)
      if sub.score do
        sub.score
      else
        "∅"
      end
    end
  end
end
