defmodule InkfishWeb.ViewHelpers do
  # Helper functions available in all templates.
  
  alias Inkfish.Users.User
  
  def user_display_name(%User{} = user) do
    "#{user.given_name} #{user.surname}"
  end
end
