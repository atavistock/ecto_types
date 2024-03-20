defmodule EctoTypes.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_types,
      version: "0.1.3",
      elixir: "~> 1.14",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.7"},
      {:credo, "~> 1.5", only: [:dev, :test]
    ]
  end
end
