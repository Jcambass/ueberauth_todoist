defmodule UeberauthTodoist.MixProject do
  use Mix.Project

  def project do
    [
      app: :ueberauth_todoist,
      name: "Ueberauth Todoist",
      package: package(),
      version: "1.0.0",
      elixir: "~> 1.14",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/jcambass/ueberauth_todoist",
      homepage_url: "https://github.com/jcambass/ueberauth_todoist",
      description: description(),
      deps: deps(),
      docs: docs(),

      # Dialyzer
      dialyzer: [
        plt_local_path: "plts",
        plt_core_path: "plts",
        plt_add_apps: [:ssl, :crypto, :mix, :ex_unit, :erts, :kernel, :stdlib]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [applications: [:logger, :ueberauth, :oauth2]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauth2, "~> 1.0 or ~> 2.0"},
      {:ueberauth, "~> 0.10.8"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ] ++
      if Version.match?(System.version(), "~> 1.12") do
        [{:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}]
      else
        []
      end
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Ueberauth strategy for using Todoist to authenticate your users."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Joel Ambass"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/jcambass/ueberauth_todoist"}
    ]
  end
end
