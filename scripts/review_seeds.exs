defmodule ReviewSeeds do
  alias Inkfish.Repo
  alias Inkfish.Assignments.Assignment
  alias Inkfish.Users
  import InkfishWeb.ViewHelpers
  import Ecto.Query, only: [from: 2]

  @project_id 11

  def get_assignment do
    Repo.one from as in Assignment,
      where: as.id == ^@project_id,
      preload: [teamset: [teams: [regs: :user, team_members: [reg: :user]]]]
  end

  def teams(as) do
    Enum.map as.teamset.teams, fn team ->
      members = show_team_members(team)
      ~s[make_team.(#{team.id}, "#{members}")]
    end
  end

  def users(as) do
    Enum.flat_map as.teamset.teams, fn team ->
      Enum.map team.regs, fn reg ->
        {:ok, user} = Users.add_secret(reg.user)
        ~s[make_user.("#{user.login}", "#{user.secret}", #{team.id})]
      end
    end
  end
end

as = ReviewSeeds.get_assignment()
teams = ReviewSeeds.teams(as)
users = ReviewSeeds.users(as)

IO.puts """


alias ProjReviews.Repo
alias ProjReviews.Users.User
alias ProjReviews.Presentations.Presentation

Repo.insert!(%User{username: "ntuck", secret: "f197a451bbd8a8b1334e0ee1172cd5660",
                   admin: true})

make_user = fn u, s, tid ->
  Repo.insert!(%User{username: u, secret: s, presentation_id: tid})
end

make_team = fn tid, names ->
  Repo.insert!(%Presentation{id: tid, names: names, order: "2020-01-01 99"})
end
"""

Enum.each teams, fn team ->
  IO.puts team
end

IO.puts ""

Enum.each users, fn user ->
  IO.puts user
end

IO.puts """


"""
