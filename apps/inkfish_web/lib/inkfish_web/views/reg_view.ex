defmodule InkfishWeb.RegView do
  use InkfishWeb, :view

  def render("reg.json", %{reg: reg}) do
    user = get_assoc(reg, :user)

    %{
      user: render_one(user, InkfishWeb.UserView, "user.json"),
    }
  end
end
