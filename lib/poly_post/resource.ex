defmodule PolyPost.Resource do
  @moduledoc """
  A behavior used to transform a resource (like a markdown file) into structured content.
  """

  @type key :: term()
  @type content :: term()
  @type tag :: atom()

  @doc "Defines a way to return the desired term for the resource"
  @callback build(reference :: String.t, metadata :: Keyword.t, body :: String.t) :: %{key: key(), content: content()}
end
