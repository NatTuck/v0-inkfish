defmodule Mix.Tasks.Db.Dump do
  use Mix.Task

  def run(_) do
    conf = Application.fetch_env!(:inkfish, Inkfish.Repo)
    cmd0 = ~s(PGPASSWORD='#{conf[:password]}' pg_dump -h '#{conf[:hostname]}' )
    cmd1 = ~s(-U '#{conf[:username]}' '#{conf[:database]}')
    cmnd = cmd0 <> cmd1
    IO.puts "#{cmnd}"
  end
end
