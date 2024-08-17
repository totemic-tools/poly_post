defmodule PolyPost.MixProject do
  use Mix.Project

  @source_url "https://github.com/totemic-tools/poly_post"
  @version "0.1.0"

  def project do
    [
      app: :poly_post,
      docs: docs(),
      version: @version,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  def application do
    [
      mod: {PolyPost, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # All
      {:earmark, "~> 1.4"},
      {:jason, "~> 1.4"},
      {:makeup, "~> 1.1"},

      # Dev
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A publishing engine with markdown and code highlighting support.
    """
  end

  defp docs do
    [
      main: "readme",
      name: "PolyPost",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/poly_post",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/fixtures"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url},
      maintainers: ["Angelo Lakra"]
    ]
  end
end
