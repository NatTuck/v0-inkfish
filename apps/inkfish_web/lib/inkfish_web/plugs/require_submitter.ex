defmodule InkfishWeb.Plugs.RequireSubmitter do
  use InkfishWeb, :controller

  # Prevent students from accessing subs, grades,
  # and line comments for other students.
  #
  # Runs after FetchItem, so path is available.

  def init(args), do: args

  def call(conn, _args \\ []) do
    user = conn.assigns[:current_user]
    reg  = conn.assigns[:current_reg]
    sub  = conn.assigns[:sub]
    asgn = conn.assigns[:assignment]

    is_staff = reg.is_staff || reg.is_prof
    on_team = Enum.any?(sub.team.regs, &(&1.id == reg.id))

    if on_team || sub.reg_id == reg.id || is_staff || user.is_admin do
      conn
    else
      conn
      |> put_flash(:error, "Access denied.")
      |> redirect(to: Routes.assignment_path(conn, :show, asgn))
      |> halt
    end
  end
end
