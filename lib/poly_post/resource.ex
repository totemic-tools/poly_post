defmodule PolyPost.Resource do
  @moduledoc """
  A behavior used to transform a resource (like a markdown file) into structured content.
  """
  @moduledoc since: "0.1.0"

  @type name :: atom()
  @type key :: term()
  @type content :: %{key: key()}

  @doc """
  Defines a way to return the desired content from the resource.

  This MAY return other keys but MUST have have a key named `key`.
  """
  @doc since: "0.1.0"
  @callback build(reference :: String.t(), metadata :: Keyword.t(), body :: String.t()) ::
              content()
end
