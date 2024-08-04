defmodule PolyPost.Resource do
  @moduledoc """
  A behavior used to transform a resource (like a markdown file) into structured content.
  """
  @moduledoc since: "0.1.0"

  @type key :: term()
  @type content :: term()
  @type tag :: atom()

  @doc """
  Defines a way to return the desired term for the resource.

  The `map` MAY contain other keys but MUST have the following keys:

  * `key`
  * `content`
  """
  @doc since: "0.1.0"
  @callback build(reference :: String.t, metadata :: Keyword.t, body :: String.t) :: %{key: key(), content: content()}
end
