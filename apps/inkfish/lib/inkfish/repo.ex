defmodule Inkfish.Repo do
  use Ecto.Repo,
    otp_app: :inkfish,
    adapter: Ecto.Adapters.Postgres
end
