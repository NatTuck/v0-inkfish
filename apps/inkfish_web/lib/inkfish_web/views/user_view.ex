defmodule InkfishWeb.UserView do
  use InkfishWeb, :view

  def render("user.json", %{user: user}) do
    %{
      name: user_display_name(user),
    }
  end
end
