defmodule Inkfish.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      version: "0.1.0",
      releases: [
        inkfish: [
          applications: [
            sandbox: :permanent,
            inkfish: :permanent,
            inkfish_web: :permanent,
          ],
        ]
      ],
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:decimal, "~> 1.8"},
      {:jason, "~> 1.1"},
      {:phoenix_integration, "~> 0.6", only: :test},
      {:hound, "~> 1.0", only: :test},
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run apps/inkfish/priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
    ]
  end
end
