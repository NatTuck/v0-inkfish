[arg1] = System.argv()

{as_id, _} = Integer.parse(arg1)

as = Inkfish.Assignments.get_assignment!(as_id)
subs = Inkfish.Assignments.list_active_subs(as)
Enum.each subs, fn sub ->
  Inkfish.Subs.calc_sub_score!(sub.id)
end
