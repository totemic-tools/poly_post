defmodule PolyPost.Resource do
  @moduledoc """
  A behavior used to transform a resource (like a markdown file) into structured content.
  """

  @typedoc "Name of an existing resource"
  @type name :: atom()

  @typedoc "The unique ID for an item belonging to a resource"
  @type key :: term()

  @typedoc "The config for a resource"
  @type config :: keyword()

  @typedoc "The content belonging to an item (includes `key`)"
  @type content :: %{key: key()}

  @doc """
  Defines a way to return the desired content from the resource.

  This MAY return other keys but MUST have have a key named `key`.
  """
  @doc since: "0.1.0"
  @callback build(reference :: String.t(), metadata :: Keyword.t(), body :: String.t()) ::
              content()
end
