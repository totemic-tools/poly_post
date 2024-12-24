defmodule PolyPost.Util do
  @moduledoc false

  @spec get_config() :: {:ok, term()} | :error
  def get_config do
    Application.fetch_env(:poly_post, :resources)
  end
end
