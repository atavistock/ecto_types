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
      {:ecto, "~> 3.0"},
      {:ex_unit, "~> 1.6", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
    ]
  end
end
