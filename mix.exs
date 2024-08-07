defmodule PolyPost.MixProject do
  use Mix.Project

  def project do
    [
      app: :poly_post,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
    ]
  end
end
