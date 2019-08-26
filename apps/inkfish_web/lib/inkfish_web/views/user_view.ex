defmodule InkfishWeb.UserView do
  use InkfishWeb, :view

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user_display_name(user),
    }
  end
end
