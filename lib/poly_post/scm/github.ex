defmodule PolyPost.Scm.Github do
  @moduledoc false

  # API

  def expand_repo(github) do
    "https://github.com/#{github}.git"
  end
end
