
as_id = 26
gc_id = 34

alias Inkfish.Assignments
alias Inkfish.Repo
alias Inkfish.LocalTime

import Ecto.Changeset

asg = Assignments.get_assignment!(as_id)
|> Repo.preload([:subs])

subs = asg.subs

regrade = fn gr ->
  IO.inspect({:gr_id, gr.id, gr.updated_at})
  {:ok, uuid} = Inkfish.Autograde.start(gr.id)
  {:ok, resp} = Inkfish.Itty.Server.open(uuid, self())
  unless resp.exit do
    receive do
      {:exit, _} -> :ok 
    end
  end 
  {:ok, gr1} = gr
  |> cast(%{updated_at: LocalTime.now()}, [:updated_at])
  |> Repo.update()

  IO.inspect({:gr1, gr1})
end

Enum.each subs, fn sub ->
  sub = Inkfish.Subs.get_sub!(sub.id)
  IO.inspect({:sub, sub.id, sub.reg.user.login})

  if sub.active do
    Enum.each sub.grades, fn gr ->
      cmp = NaiveDateTime.compare(gr.updated_at, ~N[2020-02-14 21:00:00])
      if gr.grade_column_id == gc_id && cmp == :lt do
        regrade.(gr)
      end
   end 
  end
end

