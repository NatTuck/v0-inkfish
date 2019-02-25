defmodule Mix.Tasks.Db.Console do
  use Mix.Task

  def run(_) do
    conf = Application.fetch_env!(:inkfish, Inkfish.Repo)
    cmd0 = ~s(PGPASSWORD='#{conf[:password]}' psql -h '#{conf[:hostname]}' )
    cmd1 = ~s(-U '#{conf[:username]}' '#{conf[:database]}')
    cmnd = cmd0 <> cmd1
    IO.puts "#{cmnd}"
  end
end
