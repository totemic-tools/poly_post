defmodule PolyPost do
  use Application

  alias PolyPost.{
    Builder,
    Depots,
    Depot
  }

  # API

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: PolyPost.Registry]},
      Depots
    ]

    opts = [
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end

  @doc """
  Builds a list of content for a specific markdown + metadata resource
  and store it in a `Depot` process.
  """
  @doc since: "0.1.0"
  @spec build_and_store!(Resource.name()) :: :ok
  def build_and_store!(resource) do
    resource
    |> Builder.build!()
    |> store_content(resource)

    :ok
  end

  @doc """
  Builds all the content for each  markdown + metadata resource
  and store it in a corresponding `Depot` process.
  """
  @doc since: "0.1.0"
  @spec build_and_store_all!() :: :ok
  def build_and_store_all! do
    Builder.build_all!()
    |> Enum.each(fn {resource, content} ->
      store_content(content, resource)
    end)

    :ok
  end

  # Private

  defp store_content(content, resource) do
    Enum.each(content, fn %{key: key} = data ->
      Depot.insert(resource, key, data)
    end)
  end
end
